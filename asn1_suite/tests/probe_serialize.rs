use rust_asn1::asn1_types::*;
use rust_asn1::ctx::Serializer;
use rust_asn1::der::{self, DERSerializable};
use rust_asn1::errors::ASN1Error;

struct MyStruct {
    a: i32,
    b: bool,
}

impl DERSerializable for MyStruct {
    fn serialize(&self, serializer: &mut Serializer) -> Result<(), ASN1Error> {
        // Probe for write_sequence
        serializer.write_sequence(|serializer| {
            self.a.serialize(serializer)?;
            self.b.serialize(serializer)?;
            Ok(())
        })
    }
}

#[test]
fn test_serialize() {
    let s = MyStruct { a: 1, b: true };
    let mut data = Vec::new();
    let mut serializer = Serializer::new(&mut data);
    s.serialize(&mut serializer).unwrap();
}
