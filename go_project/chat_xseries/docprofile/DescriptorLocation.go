package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorLocation struct {
    UniqueLocation asn1.ObjectIdentifier `asn1:"optional,tag:0"`
    DescriptiveLocation DescriptorCharacterData `asn1:"optional,tag:1"`
}
