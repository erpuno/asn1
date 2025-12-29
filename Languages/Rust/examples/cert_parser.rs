//! Certificate Parser Example
//!
//! Reads a certificate from filesystem (DER or PEM format),
//! parses it at both ASN.1 and high-level, prints the structure, re-encodes it,
//! and verifies compatibility with OpenSSL.
//!
//! Usage:
//!   cargo run --example cert_parser -- <path_to_certificate>
//!
//! Example:
//!   cargo run --example cert_parser -- /path/to/cert.der
//!   cargo run --example cert_parser -- /path/to/cert.pem

use std::env;
use std::fs;
use std::process::Command;

use asn1_suite::PKIX1Explicit2009Certificate;
use rust_asn1::asn1::{ASN1Node, Content};
use rust_asn1::asn1_types::*;
use rust_asn1::der::{self, DERParseable, DERSerializable, Serializer};

fn main() {
    let args: Vec<String> = env::args().collect();

    if args.len() < 2 {
        eprintln!("Usage: {} <certificate_file>", args[0]);
        eprintln!("  Supports DER and PEM formats");
        std::process::exit(1);
    }

    let cert_path = &args[1];
    println!("=== Rust Certificate Parser ===\n");
    println!("Reading certificate from: {}", cert_path);

    // Read file contents
    let file_data = match fs::read(cert_path) {
        Ok(data) => data,
        Err(e) => {
            eprintln!("Error reading file: {}", e);
            std::process::exit(1);
        }
    };

    // Detect and handle PEM vs DER
    let der_bytes = if file_data.starts_with(b"-----BEGIN") {
        println!("Detected PEM format, decoding...");
        decode_pem(&file_data)
    } else {
        println!("Detected DER format");
        file_data
    };

    println!("Certificate size: {} bytes\n", der_bytes.len());

    // Parse at the ASN.1 level
    println!("--- Parsing Certificate (ASN.1 Level) ---");
    let bytes = bytes::Bytes::from(der_bytes.clone());
    let node = match der::parse(&bytes) {
        Ok(n) => n,
        Err(e) => {
            eprintln!("Failed to parse DER: {:?}", e);
            std::process::exit(1);
        }
    };

    // Print certificate structure
    print_certificate_node(&node, 0);
    
    // Try high-level parsing
    println!("\n--- High-Level Certificate Parsing ---");
    let bytes2 = bytes::Bytes::from(der_bytes.clone());
    let node2 = der::parse(&bytes2).unwrap();
    match PKIX1Explicit2009Certificate::from_der_node(node2) {
        Ok(cert) => {
            println!("✓ High-level parsing SUCCEEDED!");
            println!("  Version: {:?}", cert.to_be_signed.version);
            println!("  Serial Number: {:?}", cert.to_be_signed.serial_number);
            println!("  Issuer: {} RDNs", match &cert.to_be_signed.issuer {
                asn1_suite::PKIX1Explicit2009Name::RdnSequence(rdns) => rdns.len(),
            });
            println!("  Subject: {} RDNs", match &cert.to_be_signed.subject {
                asn1_suite::PKIX1Explicit2009Name::RdnSequence(rdns) => rdns.len(),
            });
            if let Some(ref exts) = cert.to_be_signed.extensions {
                // Extensions is likely a tuple struct wrapping a Vec
                println!("  Extensions: {} total", exts.0.len());
            }
        }
        Err(e) => {
            println!("✗ High-level parsing FAILED: {:?}", e);
        }
    }

    // Re-encode the certificate
    println!("\n--- Re-encoding Certificate ---");
    let reencoded = reencode_node(&node);
    println!("Re-encoded size: {} bytes", reencoded.len());

    // Compare with original
    if reencoded == der_bytes {
        println!("✓ Re-encoded bytes match original exactly!");
    } else {
        println!("⚠ Re-encoded bytes differ from original");
        println!("  Original:   {} bytes", der_bytes.len());
        println!("  Re-encoded: {} bytes", reencoded.len());
        
        // Show first difference
        for (i, (a, b)) in der_bytes.iter().zip(reencoded.iter()).enumerate() {
            if a != b {
                println!("  First difference at byte {}: original={:#04x}, reencoded={:#04x}", i, a, b);
                break;
            }
        }
    }

    // Verify with OpenSSL
    println!("\n--- OpenSSL Verification ---");
    verify_with_openssl(&der_bytes, &reencoded);
}

fn decode_pem(pem_data: &[u8]) -> Vec<u8> {
    let pem_str = String::from_utf8_lossy(pem_data);
    
    // Extract base64 content between BEGIN and END markers
    let mut in_cert = false;
    let mut base64_content = String::new();
    
    for line in pem_str.lines() {
        if line.contains("-----BEGIN") {
            in_cert = true;
            continue;
        }
        if line.contains("-----END") {
            break;
        }
        if in_cert {
            base64_content.push_str(line.trim());
        }
    }
    
    // Decode base64
    match base64_decode(&base64_content) {
        Ok(bytes) => bytes,
        Err(e) => {
            eprintln!("Failed to decode PEM base64: {}", e);
            std::process::exit(1);
        }
    }
}

fn base64_decode(input: &str) -> Result<Vec<u8>, String> {
    const ALPHABET: &[u8] = b"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    
    let mut output = Vec::new();
    let mut buffer: u32 = 0;
    let mut bits_collected = 0;
    
    for c in input.bytes() {
        if c == b'=' {
            break;
        }
        if c.is_ascii_whitespace() {
            continue;
        }
        
        let value = ALPHABET.iter().position(|&x| x == c)
            .ok_or_else(|| format!("Invalid base64 character: {}", c as char))?;
        
        buffer = (buffer << 6) | (value as u32);
        bits_collected += 6;
        
        if bits_collected >= 8 {
            bits_collected -= 8;
            output.push((buffer >> bits_collected) as u8);
            buffer &= (1 << bits_collected) - 1;
        }
    }
    
    Ok(output)
}

fn print_certificate_node(node: &ASN1Node, depth: usize) {
    let indent = "  ".repeat(depth);
    // Use the standard Display implementation for ASN1Identifier
    let tag_name = format!("{}", node.identifier);
    
    match &node.content {
        Content::Constructed(children) => {
            let child_vec: Vec<_> = children.clone().into_iter().collect();
            println!("{}{} ({} children)", indent, tag_name, child_vec.len());
            
            // For top-level SEQUENCE (Certificate), annotate children
            if depth == 0 && node.identifier.tag_number == 16 && child_vec.len() >= 3 {
                println!("{}  [0] TBSCertificate:", indent);
                print_tbs_details(&child_vec[0], depth + 2);
                
                println!("{}  [1] SignatureAlgorithm:", indent);
                print_certificate_node(&child_vec[1], depth + 2);
                
                println!("{}  [2] SignatureValue: {} bytes", 
                    indent, 
                    child_vec[2].encoded_bytes.len()
                );
            } else {
                for child in child_vec {
                    print_certificate_node(&child, depth + 1);
                }
            }
        }
        Content::Primitive(data) => {
            // Simplified primitive value printing
            let preview = if data.len() < 30 && (
                node.identifier.tag_number == 12 || // UTF8String
                node.identifier.tag_number == 19 || // PrintableString
                node.identifier.tag_number == 22 || // IA5String
                node.identifier.tag_number == 23 || // UTCTime
                node.identifier.tag_number == 24    // GeneralizedTime
            ) {
                 format!("\"{}\"", String::from_utf8_lossy(data))
            } else if node.identifier.tag_number == 6 {
                 format!("OID ({} bytes)", data.len())
            } else {
                 format!("{} bytes", data.len())
            };
            println!("{}{}: {}", indent, tag_name, preview);
        }
    }
}


fn print_tbs_details(node: &ASN1Node, depth: usize) {
    let indent = "  ".repeat(depth);
    
    if let Content::Constructed(children) = &node.content {
        let child_vec: Vec<_> = children.clone().into_iter().collect();
        let mut idx = 0;
        
        // Check for version (context-specific [0])
        if idx < child_vec.len() {
            let child = &child_vec[idx];
            if child.identifier.tag_class == TagClass::ContextSpecific && 
               child.identifier.tag_number == 0 {
                println!("{}Version: [0] EXPLICIT (v3)", indent);
                idx += 1;
            }
        }
        
        // Serial Number
        if idx < child_vec.len() {
            let sn = &child_vec[idx];
            println!("{}Serial Number: {} bytes", indent, sn.encoded_bytes.len());
            idx += 1;
        }
        
        // Signature Algorithm
        if idx < child_vec.len() {
            let sig_alg = &child_vec[idx];
            if let Content::Constructed(sig_children) = &sig_alg.content {
                if let Some(oid_node) = sig_children.clone().into_iter().next() {
                    if let Content::Primitive(oid_bytes) = &oid_node.content {
                        println!("{}Signature Algorithm OID: {} bytes", indent, oid_bytes.len());
                    }
                }
            }
            idx += 1;
        }
        
        // Issuer
        if idx < child_vec.len() {
            let issuer = &child_vec[idx];
            println!("{}Issuer: {:?}", indent, format_name(issuer));
            idx += 1;
        }
        
        // Validity
        if idx < child_vec.len() {
            let validity = &child_vec[idx];
            if let Content::Constructed(val_children) = &validity.content {
                let val_vec: Vec<_> = val_children.clone().into_iter().collect();
                if val_vec.len() >= 2 {
                    println!("{}Validity:", indent);
                    println!("{}  Not Before: {:?}", indent, format_time(&val_vec[0]));
                    println!("{}  Not After:  {:?}", indent, format_time(&val_vec[1]));
                }
            }
            idx += 1;
        }
        
        // Subject
        if idx < child_vec.len() {
            let subject = &child_vec[idx];
            println!("{}Subject: {:?}", indent, format_name(subject));
            idx += 1;
        }
        
        // Subject Public Key Info
        if idx < child_vec.len() {
            let spki = &child_vec[idx];
            println!("{}SubjectPublicKeyInfo: {} bytes", indent, spki.encoded_bytes.len());
            idx += 1;
        }
        
        // Extensions (optional, context-specific [3])
        while idx < child_vec.len() {
            let ext = &child_vec[idx];
            if ext.identifier.tag_class == TagClass::ContextSpecific {
                match ext.identifier.tag_number {
                    1 => println!("{}IssuerUniqueID: [1]", indent),
                    2 => println!("{}SubjectUniqueID: [2]", indent),
                    3 => {
                        // Count extensions
                        if let Content::Constructed(ext_seq) = &ext.content {
                            if let Some(inner) = ext_seq.clone().into_iter().next() {
                                if let Content::Constructed(exts) = &inner.content {
                                    let count = exts.clone().into_iter().count();
                                    println!("{}Extensions: [3] ({} extensions)", indent, count);
                                }
                            }
                        }
                    }
                    _ => {}
                }
            }
            idx += 1;
        }
    }
}

fn format_name(node: &ASN1Node) -> String {
    // RDNSequence -> SET OF RDN -> AttributeTypeAndValue
    if let Content::Constructed(rdns) = &node.content {
        let parts: Vec<String> = rdns.clone().into_iter().filter_map(|rdn| {
            if let Content::Constructed(atvs) = &rdn.content {
                atvs.clone().into_iter().next().and_then(|atv| {
                    if let Content::Constructed(pair) = &atv.content {
                        let pair_vec: Vec<_> = pair.clone().into_iter().collect();
                        if pair_vec.len() >= 2 {
                            if let Content::Primitive(val_bytes) = &pair_vec[1].content {
                                return Some(String::from_utf8_lossy(val_bytes).to_string());
                            }
                        }
                    }
                    None
                })
            } else {
                None
            }
        }).collect();
        parts.join(", ")
    } else {
        "(empty)".to_string()
    }
}

fn format_time(node: &ASN1Node) -> String {
    if let Content::Primitive(bytes) = &node.content {
        String::from_utf8_lossy(bytes).to_string()
    } else {
        "(unknown)".to_string()
    }
}

fn reencode_node(node: &ASN1Node) -> Vec<u8> {
    let mut serializer = Serializer::new();
    if let Err(e) = node.serialize(&mut serializer) {
        eprintln!("Serialization error: {:?}", e);
        return Vec::new();
    }
    serializer.serialized_bytes().to_vec()
}

fn verify_with_openssl(original: &[u8], reencoded: &[u8]) {
    // Write both versions to temp files
    let original_path = "/tmp/cert_original.der";
    let reencoded_path = "/tmp/cert_reencoded.der";
    
    if let Err(e) = fs::write(original_path, original) {
        eprintln!("Failed to write original cert: {}", e);
        return;
    }
    
    if let Err(e) = fs::write(reencoded_path, reencoded) {
        eprintln!("Failed to write reencoded cert: {}", e);
        return;
    }
    
    println!("Testing original certificate with OpenSSL...");
    let original_result = Command::new("openssl")
        .args(["x509", "-inform", "DER", "-in", original_path, "-noout", "-text"])
        .output();
    
    match original_result {
        Ok(output) => {
            if output.status.success() {
                println!("✓ Original certificate: OpenSSL accepts it");
            } else {
                println!("✗ Original certificate: OpenSSL rejected it");
                eprintln!("{}", String::from_utf8_lossy(&output.stderr));
            }
        }
        Err(e) => {
            println!("⚠ Could not run OpenSSL: {}", e);
            println!("  Install OpenSSL to verify certificate compatibility");
            return;
        }
    }
    
    println!("Testing re-encoded certificate with OpenSSL...");
    let reencoded_result = Command::new("openssl")
        .args(["x509", "-inform", "DER", "-in", reencoded_path, "-noout", "-text"])
        .output();
    
    match reencoded_result {
        Ok(output) => {
            if output.status.success() {
                println!("✓ Re-encoded certificate: OpenSSL accepts it");
            } else {
                println!("✗ Re-encoded certificate: OpenSSL rejected it");
                eprintln!("{}", String::from_utf8_lossy(&output.stderr));
            }
        }
        Err(e) => {
            println!("⚠ Could not run OpenSSL: {}", e);
        }
    }
    
    // Compare results
    if original == reencoded {
        println!("\n✓ Byte-for-byte identical");
    } else {
        println!("\nFiles written for manual comparison:");
        println!("  {}", original_path);
        println!("  {}", reencoded_path);
        println!("  diff <(xxd {}) <(xxd {})", original_path, reencoded_path);
    }
}
