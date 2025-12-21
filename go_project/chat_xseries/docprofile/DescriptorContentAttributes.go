package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorContentAttributes struct {
    DocumentSize int64 `asn1:"optional,tag:1"`
    NumberOfPages int64 `asn1:"optional,tag:2"`
    Languages []DescriptorCharacterData `asn1:"optional,set,tag:4"`
}
