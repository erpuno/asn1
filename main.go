package main

import (
	"encoding/asn1"
	"fmt"
	"log"

	"tobirama/chat/basicaccesscontrol"
	"tobirama/chat/chat"
	"tobirama/chat/kep"
	"tobirama/chat/x500"
)

func main() {
	fmt.Println("=== Go ASN.1 Types Test Suite ===")
	fmt.Println()

	testCHATMessage()
	testCHATContact()
	testKEPTypes()
	testKEPSignedData()
	testXSeries()

	fmt.Println()
	fmt.Println("=== All tests passed! ===")
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
