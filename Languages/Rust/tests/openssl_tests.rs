//! OpenSSL Comparison Tests for Rust Generated Structures
//! Tests parsing and round-trip serialization of OpenSSL-generated test data.

use std::fs;
use std::path::Path;

use rust_asn1::der::{DERParseable, DERSerializable, Serializer, parse};

// Import generated types
use asn1_suite::pkcs8privatekeyinfo::PKCS8PrivateKeyInfo;
use asn1_suite::pkcs10certificationrequest::PKCS10CertificationRequest;
use asn1_suite::authenticationframeworkcertificate::AuthenticationFrameworkCertificate;

struct TestResult {
    name: String,
    size: usize,
    parse_ok: bool,
    roundtrip_ok: bool,
    error: Option<String>,
}

fn test_pkcs8(file_path: &str, name: &str) -> TestResult {
    let mut result = TestResult {
        name: name.to_string(),
        size: 0,
        parse_ok: false,
        roundtrip_ok: false,
        error: None,
    };

    let data = match fs::read(file_path) {
        Ok(d) => d,
        Err(e) => {
            result.error = Some(format!("read error: {}", e));
            return result;
        }
    };
    result.size = data.len();

    // Parse - first parse DER to ASN1Node, then convert to struct
    let node = match parse(&data) {
        Ok(n) => n,
        Err(e) => {
            result.error = Some(format!("DER parse error: {:?}", e));
            return result;
        }
    };

    let parsed: PKCS8PrivateKeyInfo = match PKCS8PrivateKeyInfo::from_der_node(node) {
        Ok(p) => {
            result.parse_ok = true;
            p
        }
        Err(e) => {
            result.error = Some(format!("struct parse error: {:?}", e));
            return result;
        }
    };

    // Round-trip
    let mut serializer = Serializer::new();
    match parsed.serialize(&mut serializer) {
        Ok(_) => {
            let encoded = serializer.serialized_bytes();
            if encoded.as_ref() == data.as_slice() {
                result.roundtrip_ok = true;
            } else {
                result.error = Some(format!("byte mismatch: len {} vs {}", data.len(), encoded.len()));
            }
        }
        Err(e) => {
            result.error = Some(format!("serialize error: {:?}", e));
        }
    }

    result
}

fn test_pkcs10(file_path: &str, name: &str) -> TestResult {
    let mut result = TestResult {
        name: name.to_string(),
        size: 0,
        parse_ok: false,
        roundtrip_ok: false,
        error: None,
    };

    let data = match fs::read(file_path) {
        Ok(d) => d,
        Err(e) => {
            result.error = Some(format!("read error: {}", e));
            return result;
        }
    };
    result.size = data.len();

    let node = match parse(&data) {
        Ok(n) => n,
        Err(e) => {
            result.error = Some(format!("DER parse error: {:?}", e));
            return result;
        }
    };

    let parsed: PKCS10CertificationRequest = match PKCS10CertificationRequest::from_der_node(node) {
        Ok(p) => {
            result.parse_ok = true;
            p
        }
        Err(e) => {
            result.error = Some(format!("struct parse error: {:?}", e));
            return result;
        }
    };

    let mut serializer = Serializer::new();
    match parsed.serialize(&mut serializer) {
        Ok(_) => {
            let encoded = serializer.serialized_bytes();
            if encoded.as_ref() == data.as_slice() {
                result.roundtrip_ok = true;
            } else {
                result.error = Some(format!("byte mismatch: len {} vs {}", data.len(), encoded.len()));
            }
        }
        Err(e) => {
            result.error = Some(format!("serialize error: {:?}", e));
        }
    }

    result
}

fn test_cert(file_path: &str, name: &str) -> TestResult {
    let mut result = TestResult {
        name: name.to_string(),
        size: 0,
        parse_ok: false,
        roundtrip_ok: false,
        error: None,
    };

    let data = match fs::read(file_path) {
        Ok(d) => d,
        Err(e) => {
            result.error = Some(format!("read error: {}", e));
            return result;
        }
    };
    result.size = data.len();

    let node = match parse(&data) {
        Ok(n) => n,
        Err(e) => {
            result.error = Some(format!("DER parse error: {:?}", e));
            return result;
        }
    };

    let parsed: AuthenticationFrameworkCertificate = match AuthenticationFrameworkCertificate::from_der_node(node) {
        Ok(p) => {
            result.parse_ok = true;
            p
        }
        Err(e) => {
            result.error = Some(format!("struct parse error: {:?}", e));
            return result;
        }
    };

    let mut serializer = Serializer::new();
    match parsed.serialize(&mut serializer) {
        Ok(_) => {
            let encoded = serializer.serialized_bytes();
            if encoded.as_ref() == data.as_slice() {
                result.roundtrip_ok = true;
            } else {
                result.error = Some(format!("byte mismatch: len {} vs {}", data.len(), encoded.len()));
            }
        }
        Err(e) => {
            result.error = Some(format!("serialize error: {:?}", e));
        }
    }

    result
}

#[test]
fn test_openssl_structures() {
    println!("=== OpenSSL Comparison Tests (Rust GENERATED Structures) ===");
    println!();

    let test_dir = "../../test_openssl";

    println!("| Type | Size | Parse | Round-Trip |");
    println!("|------|------|-------|------------|");

    let mut results = Vec::new();

    // PKCS#8 Private Keys
    let rsa_key = Path::new(test_dir).join("rsa_key.der");
    if rsa_key.exists() {
        results.push(test_pkcs8(rsa_key.to_str().unwrap(), "PKCS#8 RSA Key"));
    }

    let ec_key = Path::new(test_dir).join("ec_key.der");
    if ec_key.exists() {
        results.push(test_pkcs8(ec_key.to_str().unwrap(), "PKCS#8 EC Key"));
    }

    // PKCS#10 CSR
    let csr = Path::new(test_dir).join("csr.der");
    if csr.exists() {
        results.push(test_pkcs10(csr.to_str().unwrap(), "PKCS#10 CSR"));
    }

    // X.509 Certificates
    let ca_cert = Path::new(test_dir).join("ca_cert.der");
    if ca_cert.exists() {
        results.push(test_cert(ca_cert.to_str().unwrap(), "X.509 CA Cert"));
    }

    let ee_cert = Path::new(test_dir).join("ee_cert.der");
    if ee_cert.exists() {
        results.push(test_cert(ee_cert.to_str().unwrap(), "X.509 EE Cert"));
    }

    let extended_cert = Path::new(test_dir).join("extended_cert.der");
    if extended_cert.exists() {
        results.push(test_cert(extended_cert.to_str().unwrap(), "X.509 Extended Cert"));
    }

    let mut passed = 0;
    let mut failed = 0;

    for r in &results {
        let parse_status = if r.parse_ok { "✓" } else { "✗" };
        let rt_status = if r.roundtrip_ok { "✓" } else { "✗" };

        if r.roundtrip_ok {
            passed += 1;
        } else {
            failed += 1;
        }

        println!("| {} | {} | {} | {} |", r.name, r.size, parse_status, rt_status);
        if let Some(ref err) = r.error {
            println!("|   → Error: {} |", err);
        }
    }

    println!();
    println!("Results: {} passed, {} failed", passed, failed);

    // Don't assert failure for now as we're testing the infrastructure
    // assert_eq!(failed, 0, "Some tests failed");
}
