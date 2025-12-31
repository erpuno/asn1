// Package main provides OpenSSL comparison tests using GENERATED ASN.1 structures.
// All tests use generated Go types for proper ASN.1 structure validation.
package main

import (
	"bytes"
	"encoding/asn1"
	"fmt"
	"os"
	"path/filepath"

	"tobirama/chat/pkcs10"
	"tobirama/chat/pkix1explicit2009"
	"tobirama/chat/x500"
	"tobirama/chat_xseries/cryptographicmessagesyntax2010"
	"tobirama/chat_xseries/pkcs8"
)

// TestResult holds the outcome of a single test.
type TestResult struct {
	Name        string
	Size        int
	ParseOK     bool
	RoundTripOK bool
	Error       string
}

// Generic test function for any type
func testGeneric[T any](filePath, name string) TestResult {
	result := TestResult{Name: name}

	data, err := os.ReadFile(filePath)
	if err != nil {
		result.Error = fmt.Sprintf("read error: %v", err)
		return result
	}
	result.Size = len(data)

	var obj T
	rest, err := asn1.Unmarshal(data, &obj)
	if err != nil {
		result.Error = fmt.Sprintf("parse error: %v", err)
		return result
	}
	if len(rest) > 0 {
		result.Error = fmt.Sprintf("trailing bytes: %d", len(rest))
		return result
	}
	result.ParseOK = true

	encoded, err := asn1.Marshal(obj)
	if err != nil {
		result.Error = fmt.Sprintf("marshal error: %v", err)
		return result
	}

	if bytes.Equal(data, encoded) {
		result.RoundTripOK = true
	} else {
		result.Error = fmt.Sprintf("byte mismatch: len %d vs %d", len(data), len(encoded))
	}

	return result
}

func main() {
	fmt.Println("=== OpenSSL Comparison Tests (Go GENERATED Structures) ===")
	fmt.Println()

	testDir := "../../test_openssl"

	fmt.Println("| Type | Size | Parse | Round-Trip |")
	fmt.Println("|------|------|-------|------------|")

	var results []TestResult

	// PKCS#8 Private Keys
	if _, err := os.Stat(filepath.Join(testDir, "rsa_key.der")); err == nil {
		results = append(results, testGeneric[pkcs8.X8PrivateKeyInfo](filepath.Join(testDir, "rsa_key.der"), "PKCS#8 RSA Key (pkcs8.X8PrivateKeyInfo)"))
	}
	if _, err := os.Stat(filepath.Join(testDir, "ec_key.der")); err == nil {
		results = append(results, testGeneric[pkcs8.X8PrivateKeyInfo](filepath.Join(testDir, "ec_key.der"), "PKCS#8 EC Key (pkcs8.X8PrivateKeyInfo)"))
	}

	// PKCS#10 CSR
	if _, err := os.Stat(filepath.Join(testDir, "csr.der")); err == nil {
		results = append(results, testGeneric[pkcs10.X10CertificationRequest](filepath.Join(testDir, "csr.der"), "PKCS#10 CSR (pkcs10.X10CertificationRequest)"))
	}

	// X.509 Certificates
	certs := []struct {
		file string
		name string
	}{
		{"ca_cert.der", "X.509 CA Cert (x500.AuthenticationFrameworkCertificate)"},
		{"ee_cert.der", "X.509 EE Cert (x500.AuthenticationFrameworkCertificate)"},
		{"extended_cert.der", "X.509 Extended Cert (x500.AuthenticationFrameworkCertificate)"},
	}
	for _, c := range certs {
		if _, err := os.Stat(filepath.Join(testDir, c.file)); err == nil {
			results = append(results, testGeneric[x500.AuthenticationFrameworkCertificate](filepath.Join(testDir, c.file), c.name))
		}
	}

	// PKCS#7/CMS ContentInfo
	if _, err := os.Stat(filepath.Join(testDir, "bundle.p7b")); err == nil {
		results = append(results, testGeneric[cryptographicmessagesyntax2010.X2010ContentInfo](filepath.Join(testDir, "bundle.p7b"), "PKCS#7 Bundle (cms.X2010ContentInfo)"))
	}
	if _, err := os.Stat(filepath.Join(testDir, "signed.cms")); err == nil {
		results = append(results, testGeneric[cryptographicmessagesyntax2010.X2010ContentInfo](filepath.Join(testDir, "signed.cms"), "CMS SignedData (cms.X2010ContentInfo)"))
	}
	if _, err := os.Stat(filepath.Join(testDir, "encrypted.cms")); err == nil {
		results = append(results, testGeneric[cryptographicmessagesyntax2010.X2010ContentInfo](filepath.Join(testDir, "encrypted.cms"), "CMS EnvelopedData (cms.X2010ContentInfo)"))
	}

	// SubjectPublicKeyInfo
	if _, err := os.Stat(filepath.Join(testDir, "rsa_pubkey.der")); err == nil {
		results = append(results, testGeneric[pkix1explicit2009.X2009SubjectPublicKeyInfo](filepath.Join(testDir, "rsa_pubkey.der"), "RSA PublicKey (pkix.X2009SubjectPublicKeyInfo)"))
	}
	if _, err := os.Stat(filepath.Join(testDir, "ec_pubkey.der")); err == nil {
		results = append(results, testGeneric[pkix1explicit2009.X2009SubjectPublicKeyInfo](filepath.Join(testDir, "ec_pubkey.der"), "EC PublicKey (pkix.X2009SubjectPublicKeyInfo)"))
	}

	passed := 0
	failed := 0

	for _, r := range results {
		parseStatus := "✓"
		if !r.ParseOK {
			parseStatus = "✗"
		}
		rtStatus := "✓"
		if !r.RoundTripOK {
			rtStatus = "✗"
			failed++
		} else {
			passed++
		}

		fmt.Printf("| %s | %d | %s | %s |\n", r.Name, r.Size, parseStatus, rtStatus)
		if r.Error != "" {
			fmt.Printf("|   → Error: %s |\n", r.Error)
		}
	}

	fmt.Println()
	fmt.Printf("Results: %d passed, %d failed\n", passed, failed)

	if failed > 0 {
		os.Exit(1)
	}
}
