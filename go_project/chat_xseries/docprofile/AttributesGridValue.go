package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesGridValue struct {
    XValue float64 `asn1:"tag:0"`
    YValue float64 `asn1:"tag:1"`
    ZValue float64 `asn1:"tag:2"`
}
