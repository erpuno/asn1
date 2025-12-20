use asn1_suite::generated::authentication_framework_algorithm_identifier::AuthenticationFrameworkAlgorithmIdentifier;
use asn1_suite::generated::kep_message_imprint::KEPMessageImprint;
use rust_asn1::asn1::ASN1Node;
use rust_asn1::asn1_types::{ASN1ObjectIdentifier, ASN1OctetString};
use rust_asn1::der::{DERParseable, DERSerializable, Serializer};

#[test]
fn test_roundtrip_kep_message_imprint() {
    println!("Testing KEPMessageImprint roundtrip...");

    // Create the inner AlgorithmIdentifier
    // Note: Verify if AuthenticationFrameworkAlgorithmIdentifier is the correct type alias/struct used by KEPMessageImprint
    // In generated code, it uses "AlgorithmIdentifier". We assume it resolves to AuthenticationFrameworkAlgorithmIdentifier or similar.
    // If compile fails, we will adjust imports.

    let algo_oid = ASN1ObjectIdentifier::from_string("1.2.840.113549.1.1.11").unwrap(); // sha256
    let algo_id = AuthenticationFrameworkAlgorithmIdentifier {
        algorithm: algo_oid,
        parameters: None, // Optional
    };

    let hashed = ASN1OctetString::new(vec![0xDE, 0xAD, 0xBE, 0xEF]);

    // We might need to cast algo_id if the type expectation is different
    // For now, let's construct it.
    // Wait, KEPMessageImprint fields are public.

    // We need to know what "AlgorithmIdentifier" resolves to in kep_message_imprint.rs
    // Ideally we import it from there if exported, or use the exact module.
    // Let's rely on type inference or explicit import if we know the path.

    // Using the struct constructor directly
    // msg = KEPMessageImprint { hash_algorithm: algo_id ... }

    // If KEPMessageImprint expects "AlgorithmIdentifier" and we pass "AuthenticationFrameworkAlgorithmIdentifier",
    // they must be the same type.

    let msg = KEPMessageImprint {
        hash_algorithm: algo_id,
        hashed_message: hashed.clone(),
    };

    // Serialize
    let mut encoded = Vec::new();
    let mut serializer = Serializer::new(&mut encoded);
    msg.serialize(&mut serializer)
        .expect("Serialization failed");

    assert!(!encoded.is_empty(), "Encoded data should not be empty");
    println!("Encoded length: {}", encoded.len());

    // Deserialize
    // DERParseable::from_der expects &[u8] usually
    // We need to check if we can call it directly or need to parse ASN1Node first.
    // rust-asn1 likely provides a helper `from_der` on the trait or a standalone function.
    // If not, we do:
    let node = rust_asn1::der::parse(&encoded).expect("Parsing failed");
    // Wait, parse returns Vec<ASN1Node> usually (stream).
    // We expect one node.
    let node = node.get(0).expect("No node decoded").clone();

    let decoded = KEPMessageImprint::from_der_node(node).expect("Decoding failed");

    // Verify
    // Check OID in algorithm
    assert_eq!(
        decoded.hash_algorithm.algorithm.to_string(),
        "1.2.840.113549.1.1.11"
    );
    // Check hashed message
    assert_eq!(decoded.hashed_message.as_slice(), hashed.as_slice());

    println!("Roundtrip passed!");
}
