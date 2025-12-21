package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorOriginators struct {
    Organizations []DescriptorCharacterData `asn1:"optional,set,tag:0"`
    Preparers []asn1.RawValue `asn1:"optional,tag:1"`
    Owners []asn1.RawValue `asn1:"optional,tag:2"`
    Authors []asn1.RawValue `asn1:"optional,tag:3"`
}
