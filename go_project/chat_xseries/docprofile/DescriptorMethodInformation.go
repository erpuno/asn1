package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorMethodInformation struct {
    UniqueMethodInfo asn1.ObjectIdentifier `asn1:"optional,tag:0"`
    DescriptiveMethodInfo DescriptorCharacterData `asn1:"optional,tag:1"`
}
