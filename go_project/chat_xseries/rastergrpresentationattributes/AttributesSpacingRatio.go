package rastergrpresentationattributes

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesSpacingRatio struct {
    LineSpacingValue int64
    PelSpacingValue int64
}
