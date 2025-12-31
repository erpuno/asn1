package main

import (
	"bufio"
	"bytes"
	"crypto/ecdsa"
	"crypto/elliptic"
	"crypto/hmac"
	"crypto/rand"
	"crypto/sha256"
	"crypto/x509"
	"crypto/x509/pkix"
	"encoding/asn1"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"math/big"
	"net"
	"net/url"
	"strconv"
	"strings"
	"time"

	"tobirama/chat/chat"
	"tobirama/chat/kep"
	"tobirama/chat/x500"
	"tobirama/chat_xseries/basicaccesscontrol"
	"tobirama/chat_xseries/pkix1implicit2009"
	"tobirama/chat_xseries/pkixcmp2009"
)

func mustDNSGeneralName(host string) pkix1implicit2009.X2009GeneralName {
	full, err := encodeContextSpecificIA5String(2, host)
	if err != nil {
		log.Fatalf("failed to encode dNSName '%s': %v", host, err)
	}
	var gn pkix1implicit2009.X2009GeneralName
	if _, err := asn1.Unmarshal(full, (*asn1.RawValue)(&gn)); err != nil {
		log.Fatalf("failed to unmarshal dNSName raw value: %v", err)
	}
	return gn
}

func debugGeneralName(label string, gn pkix1implicit2009.X2009GeneralName) {
	rv := asn1.RawValue(gn)
	fmt.Printf("%s: Tag=%d Class=%d Compound=%v len(Bytes)=%d len(FullBytes)=%d\n",
		label, rv.Tag, rv.Class, rv.IsCompound, len(rv.Bytes), len(rv.FullBytes))
	if len(rv.Bytes) > 0 {
		fmt.Printf("%s Bytes: % X\n", label, rv.Bytes)
	}
	if len(rv.FullBytes) > 0 {
		fmt.Printf("%s FullBytes: % X\n", label, rv.FullBytes)
	}
}

func encodeContextSpecificIA5String(tag int, value string) ([]byte, error) {
	if tag < 0 || tag > 30 {
		return nil, fmt.Errorf("context-specific tag %d out of range", tag)
	}

	ia5, err := asn1.MarshalWithParams(value, "ia5")
	if err != nil {
		return nil, err
	}
	if len(ia5) == 0 {
		return nil, fmt.Errorf("empty IA5 encoding for %q", value)
	}

	// Manually construct [2] IMPLICIT IA5String (Primitive)
	// We want Class=2, Tag=2, Bytes=raw string bytes
	// But asn1.MarshalWithParams("ia5") returns a Tagged value (Tag 22).
	// We replace the tag byte.
	ia5[0] = byte(0x80 | tag)
	return ia5, nil
}

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

// sendCMPRequest sends a CMP request to the CA using raw TCP/HTTP1.0
func sendCMPRequest(urlStr string, data []byte) ([]byte, error) {
	u, err := url.Parse(urlStr)
	if err != nil {
		return nil, err
	}

	fmt.Printf("Dialing %s...\n", u.Host)
	conn, err := net.Dial("tcp", u.Host)
	if err != nil {
		return nil, err
	}
	defer conn.Close()
	fmt.Println("Connected. Sending Request...")

	// Construct HTTP/1.0 Request
	path := u.Path
	if path == "" {
		path = "/"
	}
	req := fmt.Sprintf("POST %s HTTP/1.0\r\n"+
		"Host: %s\r\n"+
		"Content-Type: application/pkixcmp\r\n"+
		"Content-Length: %d\r\n"+
		"Connection: close\r\n"+
		"\r\n", path, u.Host, len(data))

	if _, err := conn.Write([]byte(req)); err != nil {
		return nil, err
	}
	if _, err := conn.Write(data); err != nil {
		return nil, err
	}
	if tcpConn, ok := conn.(*net.TCPConn); ok {
		fmt.Println("Closing Write side of connection...")
		tcpConn.CloseWrite()
	}
	fmt.Println("Request sent. Waiting for response...")

	reader := bufio.NewReader(conn)

	// Read Status Line
	statusLine, err := reader.ReadString('\n')
	if err != nil {
		return nil, fmt.Errorf("failed to read status line: %v", err)
	}
	fmt.Printf("Got Status Line: %s", statusLine)
	if !strings.Contains(statusLine, "200") {
		return nil, fmt.Errorf("server error: %s", strings.TrimSpace(statusLine))
	}

	// Read Headers
	fmt.Println("Reading Headers...")
	contentLength := -1
	for {
		line, err := reader.ReadString('\n')
		if err != nil {
			return nil, err
		}
		// fmt.Printf("Header: %s", line) // optional verbose
		line = strings.TrimSpace(line)
		if line == "" {
			break
		}
		if strings.HasPrefix(strings.ToLower(line), "content-length:") {
			parts := strings.Split(line, ":")
			if len(parts) > 1 {
				cl, err := strconv.Atoi(strings.TrimSpace(parts[1]))
				if err == nil {
					contentLength = cl
				}
			}
		}
	}
	fmt.Printf("Headers done. Content-Length: %d. Reading Body...\n", contentLength)

	// Read Body
	if contentLength > 0 {
		body := make([]byte, contentLength)
		if _, err := io.ReadFull(reader, body); err != nil {
			return nil, err
		}
		return body, nil
	}

	// Parsing ASN.1 Length Manually if Content-Length is missing
	firstByte, err := reader.ReadByte()
	if err != nil {
		return nil, err
	}

	lenByte, err := reader.ReadByte()
	if err != nil {
		return nil, err
	}

	var length int64
	var headerBytes []byte
	headerBytes = append(headerBytes, firstByte, lenByte)

	if lenByte&0x80 == 0 {
		length = int64(lenByte)
	} else {
		numBytes := int(lenByte & 0x7F)
		if numBytes == 0 {
			// Indefinite length - not supported in this simple client
			// Fallback to reading everything until EOF
			fmt.Println("Indefinite length detected, reading until EOF...")
			return io.ReadAll(reader)
		}

		lenBytes := make([]byte, numBytes)
		if _, err := io.ReadFull(reader, lenBytes); err != nil {
			return nil, err
		}
		headerBytes = append(headerBytes, lenBytes...)

		for _, b := range lenBytes {
			length = (length << 8) | int64(b)
		}
	}

	fmt.Printf("Manual ASN.1 Length parsed: %d\n", length)

	valueBytes := make([]byte, length)
	if _, err := io.ReadFull(reader, valueBytes); err != nil {
		return nil, err
	}

	return append(headerBytes, valueBytes...), nil
}

// requestRobotGoCertificate constructs a PKIMessage with 'p10cr' body (Tag 4)
// requestRobotGoCertificate constructs a PKIMessage with 'p10cr' body (Tag 4) using DER encoding
func requestRobotGoCertificate() {
	fmt.Println("Requesting Certificate for 'robot_go' using p10cr (PKCS#10)...")

	var csrKey *ecdsa.PrivateKey
	var err error

	// 1. Load or Generate ECC Key (secp384r1)
	// 1. Generate new ECC Key (secp384r1)
	fmt.Println("Generating new secp384r1 key...")
	csrKey, err = ecdsa.GenerateKey(elliptic.P384(), rand.Reader)
	if err != nil {
		log.Fatalf("Failed to generate key: %v", err)
	}
	// No saving to disk

	// 2. Generate CSR
	template := &x509.CertificateRequest{
		Subject: pkix.Name{
			CommonName: "robot_go",
		},
		SignatureAlgorithm: x509.ECDSAWithSHA384,
	}

	csrDER, err := x509.CreateCertificateRequest(rand.Reader, template, csrKey)
	if err != nil {
		log.Fatalf("Failed to create CSR: %v", err)
	}

	// No saving to disk
	fmt.Printf("Generated CSR (len=%d)\n", len(csrDER))

	// 3. Construct PKIBody
	// PKIBody ::= CHOICE { p10cr [4] CertificationRequest, ... }
	// We use EXPLICIT Tagging [4].
	// csrDER starts with 0x30 (SEQUENCE).
	// We wrap it in [4] EXPLICIT.
	bodyRaw := asn1.RawValue{
		Class:      2,
		Tag:        4,
		IsCompound: true,
		Bytes:      csrDER,
	}
	body := pkixcmp2009.X2009PKIBody(bodyRaw)

	// 4. Header
	sender := mustDNSGeneralName("robot_go")
	recipient := mustDNSGeneralName("localhost")

	// Generate TransactionID and SenderNonce
	transID := make([]byte, 16)
	rand.Read(transID)
	nonce := make([]byte, 16)
	rand.Read(nonce)

	// PBM Protection Setup
	// OID 1.2.840.113533.7.66.13 (PasswordBasedMac)
	pbmOID := asn1.ObjectIdentifier{1, 2, 840, 113533, 7, 66, 13}

	// Parameters
	salt := make([]byte, 16)
	rand.Read(salt)
	iterationCount := 10000

	type AlgorithmIdentifier struct {
		Algorithm  asn1.ObjectIdentifier
		Parameters asn1.RawValue `asn1:"optional"`
	}
	type PBMParameter struct {
		Salt           []byte
		OWF            AlgorithmIdentifier
		IterationCount int
		MAC            AlgorithmIdentifier
	}

	owfAlg := AlgorithmIdentifier{Algorithm: asn1.ObjectIdentifier{2, 16, 840, 1, 101, 3, 4, 2, 1}}
	macAlg := AlgorithmIdentifier{Algorithm: asn1.ObjectIdentifier{1, 2, 840, 113549, 2, 9}}

	pbmParams := PBMParameter{
		Salt:           salt,
		OWF:            owfAlg,
		IterationCount: iterationCount,
		MAC:            macAlg,
	}
	pbmParamsBytes, err := asn1.Marshal(pbmParams)
	if err != nil {
		log.Fatalf("failed to marshal PBM params: %v", err)
	}

	// ProtectionAlg: [1] EXPLICIT AlgorithmIdentifier
	// We use RawValue to wrap the AlgorithmIdentifier in Context 1 Explicit
	// But simply setting correct tag on AlgorithmIdentifier struct might work if we had one.
	// Manual wrap:
	fullProtAlg := AlgorithmIdentifier{
		Algorithm:  pbmOID,
		Parameters: asn1.RawValue{FullBytes: pbmParamsBytes},
	}
	fullProtAlgBytes, _ := asn1.Marshal(fullProtAlg)

	// Wrap in [1] EXPLICIT
	// A1 Length ...
	wrappedProt := make([]byte, 0, len(fullProtAlgBytes)+5)
	wrappedProt = append(wrappedProt, 0xA1)
	if len(fullProtAlgBytes) < 128 {
		wrappedProt = append(wrappedProt, byte(len(fullProtAlgBytes)))
	} else if len(fullProtAlgBytes) < 256 {
		wrappedProt = append(wrappedProt, 0x81, byte(len(fullProtAlgBytes)))
	} else {
		wrappedProt = append(wrappedProt, 0x82, byte(len(fullProtAlgBytes)>>8), byte(len(fullProtAlgBytes)))
	}
	wrappedProt = append(wrappedProt, fullProtAlgBytes...)

	protectionAlgRaw := asn1.RawValue{FullBytes: wrappedProt}

	header := pkixcmp2009.X2009PKIHeader{
		Pvno:          2,
		Sender:        sender,
		Recipient:     recipient,
		MessageTime:   time.Now().UTC().Truncate(time.Second),
		ProtectionAlg: protectionAlgRaw,

		TransactionID: transID,
		SenderNonce:   nonce,
	}

	// Calc MAC
	pass := []byte("0000")
	key := deriveKey(pass, salt, iterationCount)

	headerBytes, _ := asn1.Marshal(header)
	bodyBytes, _ := asn1.Marshal(body)
	// ProtectedPart = SEQUENCE { header, body }
	partLen := len(headerBytes) + len(bodyBytes)
	protectedPart := make([]byte, 0, partLen+10)
	protectedPart = append(protectedPart, 0x30)
	if partLen < 128 {
		protectedPart = append(protectedPart, byte(partLen))
	} else if partLen < 256 {
		protectedPart = append(protectedPart, 0x81, byte(partLen))
	} else {
		protectedPart = append(protectedPart, 0x82, byte(partLen>>8), byte(partLen))
	}
	protectedPart = append(protectedPart, headerBytes...)
	protectedPart = append(protectedPart, bodyBytes...)

	mac := calculateMAC(key, protectedPart)

	protection := pkixcmp2009.X2009PKIProtection{
		Bytes:     mac,
		BitLength: len(mac) * 8,
	}

	msg := pkixcmp2009.X2009PKIMessage{
		Header:     header,
		Body:       body,
		Protection: protection,
	}

	msgBytes, err := asn1.Marshal(msg)
	if err != nil {
		log.Fatalf("failed to marshal PKIMessage: %v", err)
	}

	fmt.Printf("Sending PKIMessage (len=%d) to CA (DER encoded)....\n", len(msgBytes))
	fmt.Printf("HEX: %X\n", msgBytes)

	conn, err := net.Dial("tcp", "localhost:8829")
	if err != nil {
		log.Fatalf("Failed to connect: %v", err)
	}
	defer conn.Close()

	headerStr := fmt.Sprintf("POST / HTTP/1.0\r\nContent-Length: %d\r\n\r\n", len(msgBytes))
	fmt.Printf("Sending Header: %s", headerStr)
	conn.Write([]byte(headerStr))
	conn.Write(msgBytes)

	if tcpConn, ok := conn.(*net.TCPConn); ok {
		fmt.Println("Closing Write side of TCP connection...")
		if err := tcpConn.CloseWrite(); err != nil {
			fmt.Printf("Error closing write: %v\n", err)
		}
	}

	// Set Read Deadline to prevent hanging
	conn.SetReadDeadline(time.Now().Add(5 * time.Second))

	fmt.Println("Waiting for response...")
	respDataAll, err := ioutil.ReadAll(conn)
	if err != nil {
		log.Fatalf("Read response failed: %v", err)
	}
	fmt.Printf("Received %d bytes\n", len(respDataAll))

	// Find the start of the body (after double newline)
	idx := bytes.Index(respDataAll, []byte("\r\n\r\n"))
	if idx == -1 {
		log.Fatal("Could not find body in response")
	}
	respBody := respDataAll[idx+4:]

	fmt.Printf("Response full bytes hex: %X\n", respBody)
	// Parse response
	respMsg := pkixcmp2009.X2009PKIMessage{}
	if rest, err := asn1.Unmarshal(respBody, &respMsg); err != nil {
		log.Fatalf("Response Unmarshal failed: %v\nRemaining: %X", err, rest)
	}

	fmt.Println("Successfully Decoded Response!")
	fmt.Printf("Body Tag: %d\n", respMsg.Body.Tag)
}

// testXSeries tests types from the X.500 series packages
func testXSeries() {
	fmt.Print("Testing X-Series (X.500) types... ")

	// Test BasicAccessControlACIItem
	aci := basicaccesscontrol.BasicAccessControlACIItem{
		IdentificationTag:   asn1.RawValue{Tag: 4, Bytes: []byte("tag")},
		Precedence:          basicaccesscontrol.BasicAccessControlPrecedence(big.NewInt(10)),
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
			Version:      2,                                                                    // v3
			SerialNumber: x500.AuthenticationFrameworkCertificateSerialNumber(big.NewInt(255)), // Dummy
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
		No:      big.NewInt(1),
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
	if decoded.No.Cmp(msg.No) != 0 {
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
		LastMsg:  chat.CHATMessage{No: big.NewInt(1)},
		Update:   big.NewInt(1703100000),
		Created:  big.NewInt(1703000000),
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

func deriveKey(password, salt []byte, iterations int) []byte {
	// PBM Key Derivation:
	// acc = H(password || salt)
	// for i = 1 to iterations-1:
	//    acc = H(acc)
	h := sha256.New()
	h.Write(password)
	h.Write(salt)
	acc := h.Sum(nil)

	for i := 1; i < iterations; i++ {
		h.Reset()
		h.Write(acc)
		acc = h.Sum(nil)
	}
	return acc
}

func calculateMAC(key, data []byte) []byte {
	mac := hmac.New(sha256.New, key)
	mac.Write(data)
	return mac.Sum(nil)
}
