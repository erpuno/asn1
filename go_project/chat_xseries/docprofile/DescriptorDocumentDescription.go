package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorDocumentDescription struct {
    Title DescriptorCharacterData `asn1:"optional,tag:0"`
    Subject DescriptorCharacterData `asn1:"optional,tag:1"`
    DocumentType DescriptorCharacterData `asn1:"optional,tag:2"`
    Abstract DescriptorCharacterData `asn1:"optional,tag:3"`
    Keywords []DescriptorCharacterData `asn1:"optional,set,tag:4"`
    DocumentReference DescriptorDocumentReference `asn1:"optional,tag:5"`
}
