package characterpresentationattributes

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesKerningOffset struct {
    StartOffset int64 `asn1:"tag:0"`
    EndOffset int64 `asn1:"tag:1"`
}
