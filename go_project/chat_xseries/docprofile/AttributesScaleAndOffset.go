package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesScaleAndOffset struct {
    ColourScale AttributesRealOrInt `asn1:"tag:0"`
    ColourOffset AttributesRealOrInt `asn1:"tag:1"`
}
