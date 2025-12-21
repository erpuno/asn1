package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesCIERef struct {
    XnValue AttributesRealOrInt `asn1:"tag:0"`
    YnValue AttributesRealOrInt `asn1:"tag:1"`
    ZnValue AttributesRealOrInt `asn1:"tag:2"`
}
