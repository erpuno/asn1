package characterpresentationattributes

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesFontType struct {
    FontSize int64 `asn1:"tag:0"`
    FontIdentifier int64 `asn1:"tag:1"`
}
