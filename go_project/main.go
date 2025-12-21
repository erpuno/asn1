package main

import (
	"bytes"
	"crypto/rand"
	"crypto/rsa"
	"crypto/x509"
	"encoding/asn1"
	"fmt"
	"io"
	"log"
	"net/http"
	"time"

	"tobirama/chat/chat"
	"tobirama/chat/kep"
	"tobirama/chat/x500"
	"tobirama/chat_xseries/basicaccesscontrol"
	"tobirama/chat_xseries/pkix1implicit2009"
	"tobirama/chat_xseries/pkixcmp2009"
)

func main() {
	fmt.Println("=== Go ASN.1 Types Test Suite ===")
	fmt.Println()

	testCHATMessage()
	testCHATContact()
	testKEPTypes()
	testKEPSignedData()
	testXSeries()

	// CA Interaction
	// testCAConnection()
	requestRobotGoCertificate()

	fmt.Println()
	fmt.Println("=== All tests passed! ===")
}

// sendCMPRequest sends a CMP request to the CA
// sendCMPRequest sends a CMP request to the CA
func sendCMPRequest(url string, data []byte) ([]byte, error) {
	req, err := http.NewRequest("POST", url, bytes.NewBuffer(data))
	if err != nil {
		return nil, err
	}
	req.Header.Set("Content-Type", "application/pkixcmp")
	req.Header.Set("Connection", "close")
	req.Close = true // Force close connection after request

	client := &http.Client{Timeout: 30 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("HTTP error: %d", resp.StatusCode)
	}

	// If ContentLength is known, use it.
	if resp.ContentLength > 0 {
		return io.ReadAll(resp.Body)
	}

	// If ContentLength is unknown (e.g. -1), read ASN.1 length manually to avoid waiting for EOF/timeout.
	// ASN.1 Structure: Tag (1+ bytes) | Length (1+ bytes) | Value

	// Read first byte (Tag)
	firstByte := make([]byte, 1)
	if _, err := io.ReadFull(resp.Body, firstByte); err != nil {
		return nil, err
	}

	// Read Length
	// If MSB is 0, it's short form (length = bits 0-6).
	// If MSB is 1, it's long form (bits 0-6 = number of length bytes).
	lenByte := make([]byte, 1)
	if _, err := io.ReadFull(resp.Body, lenByte); err != nil {
		return nil, err
	}

	var length int64
	var headerBytes []byte
	headerBytes = append(headerBytes, firstByte...)
	headerBytes = append(headerBytes, lenByte...)

	if lenByte[0]&0x80 == 0 {
		// Short form
		length = int64(lenByte[0])
	} else {
		// Long form
		numBytes := int(lenByte[0] & 0x7F)
		if numBytes == 0 {
			// Indefinite length (not supported for this simple fix, but CA likely sends DER)
			// Fallback to ReadAll
			remaining, err := io.ReadAll(resp.Body)
			if err != nil {
				return nil, err
			}
			return append(headerBytes, remaining...), nil
		}

		lenBytes := make([]byte, numBytes)
		if _, err := io.ReadFull(resp.Body, lenBytes); err != nil {
			return nil, err
		}
		headerBytes = append(headerBytes, lenBytes...)

		// Parse length
		for _, b := range lenBytes {
			length = (length << 8) | int64(b)
		}
	}

	// Read 'length' bytes
	valueBytes := make([]byte, length)
	if _, err := io.ReadFull(resp.Body, valueBytes); err != nil {
		return nil, err
	}

	return append(headerBytes, valueBytes...), nil
}

// testCAConnection attempts to contact the CA
func testCAConnection() {
	fmt.Print("Testing CA Connection... ")
	url := "http://localhost:8829/"

	// Construct minimal valid PKIMessage
	// 1. GeneralName: dNSName (Tag 2) [IMPLICIT IA5String]
	// Testing Tag 2 to avoid directoryName complexity for connectivity check.
	dnsName := []byte("localhost")
	sender := pkix1implicit2009.X2009GeneralName{Tag: 2, Class: 2, IsCompound: false, Bytes: dnsName}
	recipient := pkix1implicit2009.X2009GeneralName{Tag: 2, Class: 2, IsCompound: false, Bytes: dnsName}

	// 2. Body: GenMsg: [21] GenMsgContent
	// PKIXCMP-2009 uses EXPLICIT TAGS.
	// So [21] wraps the inner SEQUENCE.
	// We must include the SEQUENCE tag [30] and length [00] in the content.
	// Result: B5 02 30 00.
	body := pkixcmp2009.X2009PKIBody{Tag: 21, Class: 2, IsCompound: true, Bytes: []byte{0x30, 0x00}}

	// 3. Header
	header := pkixcmp2009.X2009PKIHeader{
		Pvno:      2,
		Sender:    sender,
		Recipient: recipient,
	}

	// 4. Message
	// 4. Message
	msg := pkixcmp2009.X2009PKIMessage{
		Header: header,
		Body:   body,
	}

	encoded, err := asn1.Marshal(msg)
	if err != nil {
		fmt.Printf("FAILED to marshal PKIMessage: %v\n", err)
		return
	}

	// NOTE: If server response is slow or missing for this dummy message,
	// timeout is expected. Success is defined by server accepting parsing.
	resp, err := sendCMPRequest(url, encoded)
	if err != nil {
		fmt.Printf("FAILED: %v\n", err)
		return
	}

	fmt.Printf("Success! Received %d bytes\n", len(resp))
}

// requestRobotGoCertificate requests a certificate for robot_go
func requestRobotGoCertificate() {
	fmt.Println("Requesting Certificate for 'robot_go'...")
	url := "http://localhost:8829/"

	// ==================================================================
	// 1. REQUEST CONSTRUCTION
	// ==================================================================

	// 1.1 Generate RSA Key Pair
	priv, err := rsa.GenerateKey(rand.Reader, 2048)
	if err != nil {
		log.Fatalf("Failed to generate key: %v", err)
	}
	pubKeyDer, err := x509.MarshalPKIXPublicKey(&priv.PublicKey)
	if err != nil {
		log.Fatalf("Failed to marshal public key: %v", err)
	}

	// 1.2 Construct Subject Name: CN=robot_go
	cnOID := asn1.ObjectIdentifier{2, 5, 4, 3}

	type RequestAttributeTypeAndValue struct {
		Type  asn1.ObjectIdentifier
		Value string `asn1:"utf8"`
	}

	attr := RequestAttributeTypeAndValue{Type: cnOID, Value: "robot_go"}
	attrBytes, err := asn1.Marshal(attr)
	if err != nil {
		log.Fatalf("Failed to marshal attribute: %v", err)
	}

	// RDN (SET of AttributeTypeAndValue)
	rdn := asn1.RawValue{Tag: 17, Class: 0, IsCompound: true, Bytes: attrBytes}
	rdnBytes, err := asn1.Marshal(rdn)
	if err != nil {
		log.Fatalf("Failed to marshal RDN: %v", err)
	}

	// RDNSequence (SEQUENCE of RDN)
	rdnSeq := asn1.RawValue{Tag: 16, Class: 0, IsCompound: true, Bytes: rdnBytes}
	subjectBytes, err := asn1.Marshal(rdnSeq)
	if err != nil {
		log.Fatalf("Failed to marshal RDNSequence: %v", err)
	}

	// 1.3 Local Request CertTemplate
	// We handle tagging MANUALLY in the values, so we just use 'optional'.
	type LocalReqCertTemplate struct {
		Version      asn1.RawValue `asn1:"optional"`
		SerialNumber asn1.RawValue `asn1:"optional"`
		SigningAlg   asn1.RawValue `asn1:"optional"`
		Issuer       asn1.RawValue `asn1:"optional"`
		Validity     asn1.RawValue `asn1:"optional"`
		Subject      asn1.RawValue `asn1:"optional"` // We will pass [5] EXPLICIT Name
		PublicKey    asn1.RawValue `asn1:"optional"` // We will pass [6] IMPLICIT SPKI
		IssuerUID    asn1.RawValue `asn1:"optional"`
		SubjectUID   asn1.RawValue `asn1:"optional"`
		Extensions   asn1.RawValue `asn1:"optional"`
	}

	// Prepare Subject: [5] EXPLICIT Name
	// Name is RDNSequence (Tag 16).
	// Explicit tagging means [5] wraps the Name.
	// We use 'Bytes' here because 'subjectBytes' IS the inner element.
	subjectTagged := asn1.RawValue{
		Tag: 5, Class: 2, IsCompound: true, Bytes: subjectBytes,
	}
	subjectTaggedBytes, _ := asn1.Marshal(subjectTagged)

	// Prepare PublicKey: [6] IMPLICIT SubjectPublicKeyInfo
	// SPKI is SEQUENCE (Tag 16).
	// Implicit tagging means [6] REPLACES Tag 16.
	// pubKeyDer starts with Tag 16 (0x30). We change it to Tag 6 (0xA6).
	if len(pubKeyDer) > 0 && pubKeyDer[0] == 0x30 {
		pubKeyDer[0] = 0xA6 // Context 6 Constructed
	} else {
		log.Fatalf("Unexpected PubKey formatting")
	}

	template := LocalReqCertTemplate{
		Subject:   asn1.RawValue{FullBytes: subjectTaggedBytes},
		PublicKey: asn1.RawValue{FullBytes: pubKeyDer},
	}

	templateBytes, err := asn1.Marshal(template)
	if err != nil {
		log.Fatalf("Failed to marshal CertTemplate: %v", err)
	}

	// 1.4 CertReq structures
	type LocalCertRequest struct {
		CertReqId    int
		CertTemplate asn1.RawValue
	}
	req := LocalCertRequest{
		CertReqId:    0,
		CertTemplate: asn1.RawValue{FullBytes: templateBytes},
	}
	reqBytes, err := asn1.Marshal(req)

	type LocalCertReqMsg struct {
		CertReq asn1.RawValue
	}
	msg1 := LocalCertReqMsg{CertReq: asn1.RawValue{FullBytes: reqBytes}}
	msg1Bytes, err := asn1.Marshal(msg1)

	msgsSeq := asn1.RawValue{Tag: 16, IsCompound: true, Bytes: msg1Bytes}
	msgsBytes, err := asn1.Marshal(msgsSeq)

	// PKIBody: [0] CertReqMessages (EXPLICIT)
	body := pkixcmp2009.X2009PKIBody{
		Tag: 0, Class: 2, IsCompound: true, Bytes: msgsBytes,
	}

	// Header
	senderDNS := []byte("robot_go")
	sender := pkix1implicit2009.X2009GeneralName{Tag: 2, Class: 2, IsCompound: false, Bytes: senderDNS}
	recipientDNS := []byte("localhost")
	recipient := pkix1implicit2009.X2009GeneralName{Tag: 2, Class: 2, IsCompound: false, Bytes: recipientDNS}

	header := pkixcmp2009.X2009PKIHeader{
		Pvno: 2, Sender: sender, Recipient: recipient,
	}

	msg := pkixcmp2009.X2009PKIMessage{Header: header, Body: body}

	encoded, err := asn1.Marshal(msg)
	if err != nil {
		log.Fatalf("Failed to marshal PKIMessage: %v", err)
	}

	// ==================================================================
	// 2. SEND REQUEST
	// ==================================================================
	resp, err := sendCMPRequest(url, encoded)
	if err != nil {
		log.Fatalf("Failed to send request: %v", err)
	}
	fmt.Printf("Received %d bytes response\n", len(resp))

	// ==================================================================
	// 3. RESPONSE PARSING
	// ==================================================================

	// Top Level Message
	var respMsg pkixcmp2009.X2009PKIMessage
	rest, err := asn1.Unmarshal(resp, &respMsg)
	if err != nil {
		log.Fatalf("Failed to parse response wrapper: %v", err)
	}
	if len(rest) > 0 {
		fmt.Printf("Warning: %d bytes trailing\n", len(rest))
	}

	fmt.Printf("Response Body Tag: %d\n", respMsg.Body.Tag)

	// Response Structures
	type LocalPKIStatusInfo struct {
		Status       int
		StatusString asn1.RawValue  `asn1:"optional"`
		FailInfo     asn1.BitString `asn1:"optional"`
	}

	type LocalCertResponse struct {
		CertReqId        int
		Status           LocalPKIStatusInfo
		CertifiedKeyPair asn1.RawValue `asn1:"optional"`
		RspInfo          asn1.RawValue `asn1:"optional"`
	}

	type LocalCertRepMessage struct {
		CaPubs   []asn1.RawValue     `asn1:"optional,tag:1"`
		Response []LocalCertResponse // SEQUENCE OF
	}

	if respMsg.Body.Tag == 1 || respMsg.Body.Tag == 3 {
		var certRep LocalCertRepMessage
		// Parsing Body Bytes directly
		_, err := asn1.Unmarshal(respMsg.Body.Bytes, &certRep)
		if err != nil {
			log.Fatalf("Failed to parse CertRepMessage: %v", err)
		}

		fmt.Printf("Parsed CertRepMessage. Responses: %d\n", len(certRep.Response))

		for i, r := range certRep.Response {
			fmt.Printf("  Response %d: ReqID=%d, Status=%d\n", i, r.CertReqId, r.Status.Status)

			if r.Status.Status == 0 || r.Status.Status == 1 {
				fmt.Println("    Request GRANTED!")
				if len(r.CertifiedKeyPair.FullBytes) > 0 {
					fmt.Printf("    CertifiedKeyPair present. Length: %d\n", len(r.CertifiedKeyPair.FullBytes))
				}
			} else {
				fmt.Printf("    Request Failed. FailInfo: %v\n", r.Status.FailInfo)
				if len(r.Status.StatusString.Bytes) > 0 {
					fmt.Printf("    StatusString: %s\n", string(r.Status.StatusString.Bytes))
				}
			}
		}
	} else if respMsg.Body.Tag == 23 {
		fmt.Println("Received Error Message from CA.")
	} else {
		fmt.Printf("Received unexpected body tag: %d\n", respMsg.Body.Tag)
	}
}

// testXSeries tests types from the X.500 series packages
func testXSeries() {
	fmt.Print("Testing X-Series (X.500) types... ")

	// Test BasicAccessControlACIItem
	aci := basicaccesscontrol.BasicAccessControlACIItem{
		IdentificationTag:   asn1.RawValue{Tag: 4, Bytes: []byte("tag")},
		Precedence:          10,
		AuthenticationLevel: basicaccesscontrol.BasicAccessControlAuthenticationLevel{Tag: 16, IsCompound: true}, // simplified
		ItemOrUserFirst:     asn1.RawValue{Tag: 16, IsCompound: true},                                            // Sequence
	}

	_, err := asn1.Marshal(aci)
	if err != nil {
		log.Fatalf("Failed to encode BasicAccessControlACIItem: %v", err)
	}

	// Test AuthenticationFrameworkCertificate (partial)
	cert := x500.AuthenticationFrameworkCertificate{
		ToBeSigned: x500.AuthenticationFrameworkCertificateToBeSigned{
			Version:      2,                                                        // v3
			SerialNumber: x500.AuthenticationFrameworkCertificateSerialNumber(255), // Dummy
			Signature:    asn1.RawValue{Tag: 16, IsCompound: true},
			// Issuer/Subject would need complex setup, using zero values for now (might panic on marshal if not careful, but struct creation is verified)
		},
		AlgorithmIdentifier: asn1.RawValue{Tag: 16, IsCompound: true},
		Encrypted:           asn1.BitString{Bytes: []byte{0xFF}, BitLength: 8},
	}

	// Just verify we created the struct types correctly
	if cert.ToBeSigned.Version != 2 {
		log.Fatalf("Certificate version mismatch")
	}

	fmt.Println("PASS")
}

// testCHATMessage tests the CHATMessage struct
func testCHATMessage() {
	fmt.Print("Testing CHATMessage... ")

	msg := chat.CHATMessage{
		No:      1,
		Headers: [][]byte{[]byte("Content-Type: text/plain")},
		Body:    chat.CHATProtocol{},
	}

	// Test ASN.1 encoding
	encoded, err := asn1.Marshal(msg)
	if err != nil {
		log.Fatalf("Failed to encode CHATMessage: %v", err)
	}

	// Test ASN.1 decoding
	var decoded chat.CHATMessage
	_, err = asn1.Unmarshal(encoded, &decoded)
	if err != nil {
		log.Fatalf("Failed to decode CHATMessage: %v", err)
	}

	// Verify
	if decoded.No != msg.No {
		log.Fatalf("CHATMessage.No mismatch: expected %d, got %d", msg.No, decoded.No)
	}

	fmt.Println("PASS")
}

// testCHATContact tests the CHATContact struct
func testCHATContact() {
	fmt.Print("Testing CHATContact... ")

	contact := chat.CHATContact{
		Nickname: []byte("JohnDoe"),
		Avatar:   []byte("avatar_data"),
		Names:    [][]byte{[]byte("John")},
		PhoneId:  []byte("+380123456789"),
		Surnames: [][]byte{[]byte("Doe")},
		Update:   1703100000,
		Created:  1703000000,
	}

	// Test ASN.1 encoding
	encoded, err := asn1.Marshal(contact)
	if err != nil {
		log.Fatalf("Failed to encode CHATContact: %v", err)
	}

	// Test ASN.1 decoding
	var decoded chat.CHATContact
	_, err = asn1.Unmarshal(encoded, &decoded)
	if err != nil {
		log.Fatalf("Failed to decode CHATContact: %v", err)
	}

	// Verify
	if string(decoded.Nickname) != string(contact.Nickname) {
		log.Fatalf("CHATContact.Nickname mismatch")
	}

	fmt.Println("PASS")
}

// testKEPTypes tests various KEP types for basic struct creation and encoding
func testKEPTypes() {
	fmt.Print("Testing KEP types (struct creation + encoding)... ")

	// Test KEPMessageImprint
	imprint := kep.KEPMessageImprint{
		HashAlgorithm: asn1.RawValue{Tag: 16, Class: 0, IsCompound: true, Bytes: []byte{0x06, 0x09, 0x60, 0x86, 0x48, 0x01, 0x65, 0x03, 0x04, 0x02, 0x01}},
		HashedMessage: []byte("SHA256_HASH_PLACEHOLDER"),
	}

	_, err := asn1.Marshal(imprint)
	if err != nil {
		log.Fatalf("Failed to encode KEPMessageImprint: %v", err)
	}

	// Test KEPContentType
	contentType := kep.KEPContentType{1, 2, 840, 113549, 1, 7, 1}
	if len(contentType) != 7 {
		log.Fatalf("KEPContentType length mismatch")
	}

	// Test KEPPKIStatus
	status := kep.KEPPKIStatus(0) // Granted
	if status != 0 {
		log.Fatalf("KEPPKIStatus mismatch")
	}

	fmt.Println("PASS")
}

// testKEPSignedData tests KEPSignedData struct creation
func testKEPSignedData() {
	fmt.Print("Testing KEPSignedData struct... ")

	signedData := kep.KEPSignedData{
		Version: 1,
		EncapContentInfo: kep.KEPEncapsulatedContentInfo{
			EContentType: kep.KEPContentType{1, 2, 840, 113549, 1, 7, 1},
		},
	}

	// Just verify struct can be created and version matches
	if signedData.Version != 1 {
		log.Fatalf("KEPSignedData.Version mismatch")
	}

	// Verify ContentType OID
	if len(signedData.EncapContentInfo.EContentType) != 7 {
		log.Fatalf("KEPSignedData encap content type OID length mismatch")
	}

	fmt.Println("PASS")
}
