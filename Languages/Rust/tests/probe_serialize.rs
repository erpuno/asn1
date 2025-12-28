use rust_asn1::asn1_types::*;
use rust_asn1::der::{self, DERSerializable, Serializer};
use rust_asn1::errors::ASN1Error;

struct MyStruct {
    a: i32,
    b: bool,
}

impl DERSerializable for MyStruct {
    fn serialize(&self, _serializer: &mut Serializer) -> Result<(), ASN1Error> {
        Ok(())
    }
}

#[test]
fn test_serialize() {
    let _s = MyStruct { a: 1, b: true };
    let _serializer = Serializer::new();
}
