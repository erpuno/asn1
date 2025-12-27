package main

import (
	"encoding/asn1"
	"testing"
	"time"

	"tobirama/chat/pkix1explicit88"
	"tobirama/chat/x500"
)

func TestCertificateMarshal(t *testing.T) {
	// Create a dummy certificate
	cert := pkix1explicit88.PKIX1Explicit88Certificate{
		TbsCertificate: pkix1explicit88.PKIX1Explicit88TBSCertificate{
			Version:      pkix1explicit88.PKIX1Explicit88VersionV3,
			SerialNumber: pkix1explicit88.PKIX1Explicit88CertificateSerialNumber(1),
			Signature:    asn1.RawValue{Tag: asn1.TagSequence, IsCompound: true},
			Issuer:       pkix1explicit88.PKIX1Explicit88Name{Tag: asn1.TagSequence, IsCompound: true},
			Validity: pkix1explicit88.PKIX1Explicit88Validity{
				NotBefore: time.Now(),
				NotAfter:  time.Now().Add(24 * time.Hour),
			},
			Subject:              pkix1explicit88.PKIX1Explicit88Name{Tag: asn1.TagSequence, IsCompound: true},
			SubjectPublicKeyInfo: asn1.RawValue{Tag: asn1.TagSequence, IsCompound: true},
		},
		SignatureAlgorithm: asn1.RawValue{Tag: asn1.TagSequence, IsCompound: true},
		Signature:          asn1.BitString{Bytes: []byte{0}, BitLength: 8},
	}

	_, err := asn1.Marshal(cert)
	if err != nil {
		t.Errorf("Failed to marshal certificate: %v", err)
	}
}

func TestRDNSequence(t *testing.T) {
	// Test that x500 package compiles and we can use RDNSequence
	var rdnSeq x500.InformationFrameworkRDNSequence
	rdnSeq = append(rdnSeq, x500.InformationFrameworkRelativeDistinguishedName{})

	_, err := asn1.Marshal(rdnSeq)
	if err != nil {
		t.Errorf("Failed to marshal RDNSequence: %v", err)
	}
}
