package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesCIEColour struct {
    XValue AttributesRealOrInt `asn1:"tag:0"`
    YValue AttributesRealOrInt `asn1:"tag:1"`
    ZValue AttributesRealOrInt `asn1:"tag:2"`
}
