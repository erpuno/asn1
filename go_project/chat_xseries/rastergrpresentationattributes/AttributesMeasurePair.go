package rastergrpresentationattributes

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesMeasurePair struct {
    Horizontal int64 `asn1:"tag:0"`
    Vertical int64 `asn1:"tag:0"`
}
