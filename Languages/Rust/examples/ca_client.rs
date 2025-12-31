use asn1_suite::*;
use hmac::{Hmac, Mac};
use p384::ecdsa::{signature::Signer, Signature, SigningKey};
use p384::elliptic_curve::sec1::ToEncodedPoint;
use rand::rngs::OsRng;
use rand::RngCore;
use rust_asn1::asn1::{ASN1Node, Content};
use rust_asn1::asn1_types::*;
use rust_asn1::der::{DERParseable, DERSerializable, Serializer};
use rust_asn1::errors::ASN1Error;
use sha2::{Digest, Sha256};
use std::io::{Read, Write};
use std::net::TcpStream;
use std::time::SystemTime;
use chrono;

const CA_HOST: &str = "localhost:8829";

fn to_vec<T: rust_asn1::der::DERSerializable>(val: &T) -> Result<Vec<u8>, rust_asn1::errors::ASN1Error> {
    let mut s = rust_asn1::der::Serializer::new();
    val.serialize(&mut s)?;
    Ok(s.serialized_bytes().to_vec())
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    println!("=== Rust CMP Client ===");

    // 1. Generate P-384 Key
    println!("Generating P-384 Key Pair...");
    let signing_key = SigningKey::random(&mut OsRng);
    let verifying_key = signing_key.verifying_key();
    let encoded_point = verifying_key.to_encoded_point(false);
    let pub_key_bytes = encoded_point.as_bytes();

    // 2. Build PKCS#10 CSR
    println!("Building CSR...");

    // Subject: CN=robot_rust
    // PrintableString Tag = 19 (0x13)
    let common_name = "robot_c99";
    // Construct ASN1Node for PrintableString
    // Tag 19 (0x13) Universal Primitive
    let attr_val_node = ASN1Node {
         identifier: ASN1Identifier::new(19, TagClass::Universal),
         encoded_bytes: vec![0x13, common_name.len() as u8].into_iter().chain(common_name.as_bytes().iter().cloned()).collect::<Vec<u8>>().into(),
         content: Content::Primitive(common_name.as_bytes().to_vec().into()),
    };

    let atav = PKIXCommonTypes2009SingleAttribute::new(
        ASN1ObjectIdentifier::new(&[2, 5, 4, 3]).unwrap(), // commonName
        attr_val_node,
    );

    let rdn = PKIX1Explicit2009RelativeDistinguishedName(vec![atav]);
    let subject_name = PKIX1Explicit2009Name::RdnSequence(PKIX1Explicit2009RDNSequence(vec![rdn]));

    // Parameters need to be ASN1Node (generic ANY)
    // OID secp384r1: 1.3.132.0.34
    // 06 05 2B 81 04 00 22
    let curve_oid_bytes = vec![0x06, 0x05, 0x2B, 0x81, 0x04, 0x00, 0x22]; 
    // Construct ASN1Node manually from bytes (simulating parsing or primitive content)
    // Construct params bytes manually: 06 05 2B 81 04 00 22
    let params_node = ASN1Node {
         identifier: ASN1Identifier::new(6, TagClass::Universal),
         encoded_bytes: curve_oid_bytes.clone().into(),
         content: rust_asn1::asn1::Content::Primitive(curve_oid_bytes[2..].to_vec().into()),
    };

    let alg_id = AuthenticationFrameworkAlgorithmIdentifier::new(
        ASN1ObjectIdentifier::new(&[1, 2, 840, 10045, 2, 1]).unwrap(),
        Some(params_node),
    );

    let spki = PKIX1Explicit88SubjectPublicKeyInfo::new(
        alg_id,
        ASN1BitString::new(pub_key_bytes.to_vec().into(), 0).unwrap(),
    );

    let csr_info = PKCS10CertificationRequestInfo::new(
        ASN1Integer::from(0),
        subject_name,
        spki,
        PKCS10Attributes(vec![]).0,
    );

    // Serialize CSR Info for signing (Generated)
    let csr_info_der = to_vec(&csr_info)?;

    // Sign
    println!("Signing CSR...");
    let signature: Signature = signing_key.sign(&csr_info_der);
    let sig_bytes = signature.to_der();

    // Signature Algorithm: ecdsa-with-SHA384 (1.2.840.10045.4.3.3)
    let sig_alg_id = AlgorithmInformation2009Algorithm {
        algorithm: ASN1ObjectIdentifier::new(&[1, 2, 840, 10045, 4, 3, 3]).unwrap(),
        parameters: Some(ASN1Node {
             identifier: ASN1Identifier::new(5, TagClass::Universal),
             encoded_bytes: vec![0x05, 0x00].into(),
             content: Content::Primitive(bytes::Bytes::new()),
        }),
    };

    let csr = PKCS10CertificationRequest::new(
        csr_info,
        sig_alg_id,
        ASN1BitString::new(sig_bytes.as_ref().to_vec().into(), 0).unwrap(),
    );

    // 3. Build PKIMessage (p10cr)
    println!("Constructing PKIMessage...");

    let p10cr_body = PKIXCMP2009PKIBody::P10cr(csr);

    // Header
    // Sender: robot_c99
    let sender_gn = PKIX1Implicit2009GeneralName::DNSName(ASN1IA5String("robot_c99".to_string()));
    let recipient_gn = PKIX1Implicit2009GeneralName::DNSName(ASN1IA5String("localhost".to_string()));

    let mut salt = [0u8; 16];
    OsRng.fill_bytes(&mut salt);
    let mut title = [0u8; 16];
    OsRng.fill_bytes(&mut title);
    let mut nonce = [0u8; 16];
    OsRng.fill_bytes(&mut nonce);

    // PBM Parameters 
    let pbm_params_bytes = construct_pbm_params(&salt, 10000);
    // Parse the constructed PBM params bytes to get a valid ASN1Node tree for serialization
    let pbm_params_node = rust_asn1::der::parse(&pbm_params_bytes).expect("Generated PBM params should be valid BER");

    let protection_alg = AlgorithmInformation2009Algorithm {
        algorithm: ASN1ObjectIdentifier::new(&[1, 2, 840, 113533, 7, 66, 13]).unwrap(),
        parameters: Some(pbm_params_node),
    };

    let header = PKIXCMP2009PKIHeader::new(
        ASN1Integer::from(2), // pvno
        sender_gn,
        recipient_gn,
        // Manual manual generalized time node
        Some(GeneralizedTime::from(chrono::Utc::now())), // messageTime
        Some(protection_alg), 
        Some(ASN1OctetString(b"robot_go".to_vec().into())), // senderKID (Type Alias)
        None,
        Some(ASN1OctetString(title.to_vec().into())), // transactionID
        Some(ASN1OctetString(nonce.to_vec().into())), // senderNonce
        None,
        None,
        None
    );

    // Calculate Protection
    println!("Calculating Protection...");
    let password = b"0000";
    let key = derive_key(password, &salt, 10000);

    // protectedPart = Sequence { header, body }
    // Use Serializer manually for ProtectedPart sequence
    let mut pp_serializer = Serializer::new();
    pp_serializer.append_constructed_node(
        ASN1Identifier::SEQUENCE,
        &|s: &mut Serializer| {
            header.serialize(s)?;
            p10cr_body.serialize(s)?;
            Ok(())
        }
    )?;
    let protected_part_der = pp_serializer.serialized_bytes();
    println!("ProtectedPart Bytes: {:?}", protected_part_der);
    println!("ProtectedPart Len: {}", protected_part_der.len());
    let mac = calculate_mac(&key, &protected_part_der);
    println!("Calculated MAC: {:X?}", mac);
    
    let protection = ASN1BitString::new(mac.into(), 0).unwrap(); // Type Alias

    let pkix_msg = PKIXCMP2009PKIMessage::new(
        header,
        p10cr_body,
        Some(protection),
        None
    );

    // Serialize Full Message
    let msg_der = to_vec(&pkix_msg)?;
    println!("PKIMessage Size: {} bytes", msg_der.len());

    // 4. Send to CA
    let headers = format!(
        "POST / HTTP/1.0\r\n\
         Host: localhost\r\n\
         Content-Type: application/pkixcmp\r\n\
         Content-Length: {}\r\n\
         \r\n",
        msg_der.len()
    );

    println!("Connecting to {}...", CA_HOST);
    let mut stream = TcpStream::connect(CA_HOST)?;
    stream.write_all(headers.as_bytes())?;
    stream.write_all(&msg_der)?;
    println!("Request sent. Waiting for response...");

    let mut buf = [0u8; 4096];
    let n = stream.read(&mut buf)?;
    let resp_data = &buf[..n];
    println!("Received {} bytes", n);

    // Decode Response
    // Find body
    let header_end = b"\r\n\r\n";
    if let Some(idx) = resp_data.windows(4).position(|w| w == header_end) {
        let body_bytes = &resp_data[idx+4..];
        println!("Parsing response body ({} bytes)...", body_bytes.len());
        
        let node = rust_asn1::der::parse(body_bytes)?;
        let resp_msg = PKIXCMP2009PKIMessage::from_der_node(node)?;
        println!("Successfully decoded response!");
        println!("Response PVNO: {:?}", resp_msg.header.pvno);
        match resp_msg.body {
             PKIXCMP2009PKIBody::Cp(_) => println!("Body is CP (Certification Response)"),
             PKIXCMP2009PKIBody::Error(_) => println!("Body is Error Message"),
             _ => println!("Body is {:?}", resp_msg.body),
        }
    } else {
        println!("Error: Could not find HTTP/1.0 header end");
    }

    Ok(())
}

// Helpers

fn encode_len(buf: &mut Vec<u8>, len: usize) {
    if len < 128 {
        buf.push(len as u8);
    } else if len < 256 {
        buf.push(0x81);
        buf.push(len as u8);
    } else {
        buf.push(0x82);
        buf.push((len >> 8) as u8);
        buf.push((len & 0xFF) as u8);
    }
}

fn wrap_tag(buf: &mut Vec<u8>, tag: u8, content: Vec<u8>) {
    buf.push(tag);
    encode_len(buf, content.len());
    buf.extend(content);
}



fn construct_pbm_params(salt: &[u8], iter: u32) -> Vec<u8> {
    // Sequence
    let mut s = Vec::new();
    // Salt (OctetString) 04 Len Bytes
    s.push(0x04);
    encode_len(&mut s, salt.len());
    s.extend_from_slice(salt);
    
    // OWF (AlgId -> SHA256)
    // 30 0D 06 09 60 86 48 01 65 03 04 02 01 05 00
    let sha256_oid = vec![0x06, 0x09, 0x60, 0x86, 0x48, 0x01, 0x65, 0x03, 0x04, 0x02, 0x01];
    let mut owf = Vec::new();
    owf.extend(sha256_oid);
    // Add NULL param
    owf.push(0x05);
    owf.push(0x00);
    // wrap in seq
    wrap_tag(&mut s, 0x30, owf);
    
    // Iteration (Integer)
    // 02 Len Bytes
    let mut i = Vec::new();
    let ib = iter.to_be_bytes(); 
    // minimal encoding needed? 
    // 10000 = 2710
    // 02 02 27 10
    i.push(0x02);
    i.push(0x02);
    i.push(0x27);
    i.push(0x10);
    s.extend(i);
    
    // MAC (AlgId -> HMAC-SHA256)
    // 30 0C 06 08 2A 86 48 86 F7 0D 02 09 05 00
    let hmac_oid = vec![0x06, 0x08, 0x2A, 0x86, 0x48, 0x86, 0xF7, 0x0D, 0x02, 0x09];
    let mut mac = Vec::new();
    mac.extend(hmac_oid);
    // Add NULL param
    mac.push(0x05);
    mac.push(0x00);
    wrap_tag(&mut s, 0x30, mac);
    
    // Wrap everything in SEQUENCE
    let mut seq = Vec::new();
    wrap_tag(&mut seq, 0x30, s);
    seq
}

fn derive_key(password: &[u8], salt: &[u8], iterations: usize) -> Vec<u8> {
    let mut hasher = Sha256::new();
    hasher.update(password);
    hasher.update(salt);
    let mut acc = hasher.finalize();

    for _ in 1..iterations {
        let mut h = Sha256::new();
        h.update(acc);
        acc = h.finalize();
    }
    acc.to_vec()
}

fn calculate_mac(key: &[u8], data: &[u8]) -> Vec<u8> {
    type HmacSha256 = Hmac<Sha256>;
    let mut mac = HmacSha256::new_from_slice(key).expect("HMAC can take key of any size");
    mac.update(data);
    mac.finalize().into_bytes().to_vec()
}

