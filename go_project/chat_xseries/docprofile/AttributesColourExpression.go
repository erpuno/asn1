package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesColourExpression struct {
    ColourAccessMode int64 `asn1:"tag:0"`
    A asn1.RawValue `asn1:"tag:1"`
}
