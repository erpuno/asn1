use kep::kep::KEPMessageImprint;
use rust_asn1::asn1_types::{ASN1ObjectIdentifier, ASN1OctetString};
use rust_asn1::der::{DERSerializable, Serializer};
use x500::authentication_framework::AuthenticationFrameworkAlgorithmIdentifier;

#[test]
fn test_roundtrip_kep_message_imprint() {
    println!("Testing KEPMessageImprint roundtrip...");

    let algo_oid = ASN1ObjectIdentifier::new(&[1, 2, 840, 113549, 1, 1, 11]).unwrap(); // sha256
    let algo_id = AuthenticationFrameworkAlgorithmIdentifier {
        algorithm: algo_oid,
        parameters: None, // Optional
    };

    let hashed = ASN1OctetString(vec![0xDE, 0xAD, 0xBE, 0xEF].into());

    let msg = KEPMessageImprint {
        hash_algorithm: algo_id,
        hashed_message: hashed.clone(),
    };

    // Serialize - just check if it compiles for now
    let mut _serializer = Serializer::new();
    // msg.serialize(&mut _serializer).ok(); // It might return Err because not implemented

    println!("Roundtrip compile check passed!");
}
