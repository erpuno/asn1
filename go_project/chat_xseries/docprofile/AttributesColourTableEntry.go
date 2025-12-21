package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesColourTableEntry struct {
    Index int64 `asn1:"tag:3"`
    R AttributesRealOrInt `asn1:"tag:0"`
    G AttributesRealOrInt `asn1:"tag:1"`
    B AttributesRealOrInt `asn1:"tag:2"`
}
