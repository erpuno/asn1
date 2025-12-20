use rust_asn1::asn1::ASN1Node;

fn probe() {
    let mock_node = unsafe { std::mem::zeroed::<ASN1Node>() };
    let _ = mock_node;
}
