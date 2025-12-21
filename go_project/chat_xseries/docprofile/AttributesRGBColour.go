package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesRGBColour struct {
    RValue AttributesRealOrInt `asn1:"tag:0"`
    GValue AttributesRealOrInt `asn1:"tag:1"`
    BValue AttributesRealOrInt `asn1:"tag:2"`
}
