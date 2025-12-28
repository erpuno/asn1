// Certificate parsing test suite - Rust equivalent of Swift's showCertificateData
// Tests parsing X.509 certificates from DER-encoded bytes

use rust_asn1::der::{self, DERParseable};
use x500::authentication_framework::AuthenticationFrameworkCertificate;

/// Test parsing a minimal X.509 certificate structure
/// This uses the same DER bytes from Swift's main.swift:showCertificateData test
#[test]
fn test_parse_certificate() {
    println!("Testing certificate parsing...");

    // This is the exact DER-encoded certificate from Swift's showCertificateData test
    // Minimal X.509 Certificate structure:
    // - TBSCertificate with version v3, serial 0x01E240
    // - ECDSA-SHA256 signature algorithm (1.2.840.10045.4.3.2)
    // - Issuer: CN=CA
    // - Validity: 2023-01-01 to 2030-01-01
    // - Subject: CN=User
    // - SubjectPublicKeyInfo with EC public key
    let cert_der: &[u8] = &[
        48, 129, 129, 48, 107, 160, 3, 2, 1, 2, 2, 3, 1, 226, 64, 48, 10, 6, 8, 42, 134, 72, 206,
        61, 4, 3, 2, 48, 13, 49, 11, 48, 9, 6, 3, 85, 4, 3, 19, 2, 67, 65, 48, 30, 23, 13, 50, 51,
        48, 49, 48, 49, 49, 50, 48, 48, 48, 48, 90, 23, 13, 51, 48, 48, 49, 48, 49, 49, 50, 48, 48,
        48, 48, 90, 48, 15, 49, 13, 48, 11, 6, 3, 85, 4, 3, 19, 4, 85, 115, 101, 114, 48, 19, 48,
        9, 6, 7, 42, 134, 72, 206, 61, 2, 1, 3, 6, 0, 4, 0, 0, 0, 0, 48, 10, 6, 8, 42, 134, 72,
        206, 61, 4, 3, 2, 3, 6, 0, 1, 2, 3, 4, 5,
    ];

    // Parse DER bytes into ASN.1 nodes
    let root_node = der::parse(cert_der).expect("Failed to parse DER bytes");

    // Parse into Certificate structure
    let cert = AuthenticationFrameworkCertificate::from_der_node(root_node)
        .expect("Failed to parse certificate");

    println!("Certificate parsed successfully!");
    println!("  ToBeSigned: {:?}", cert.to_be_signed);
    println!("  Algorithm: {:?}", cert.algorithm_identifier);
    println!("  Signature: {} bytes", cert.encrypted.bytes.len());

    // Basic assertions
    assert!(
        !cert.encrypted.bytes.is_empty(),
        "Signature should not be empty"
    );
}

/// Test parsing a simple TBSCertificate separately
#[test]
fn test_import_x500_crate() {
    // Simple smoke test to verify the x500 crate is correctly imported
    // and types are accessible
    println!("X500 crate types are accessible!");

    // Just verify we can reference the type (compile-time check)
    fn _type_check() -> Option<AuthenticationFrameworkCertificate> {
        None
    }
}
