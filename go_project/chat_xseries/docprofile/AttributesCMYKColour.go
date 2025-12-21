package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesCMYKColour struct {
    CValue AttributesRealOrInt `asn1:"tag:0"`
    MValue AttributesRealOrInt `asn1:"tag:1"`
    YValue AttributesRealOrInt `asn1:"tag:2"`
    KValue AttributesRealOrInt `asn1:"optional,tag:3"`
}
