package geogrpresentationattributes

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesPatternTableElement struct {
    PatternTableIndex int64
    Nx int64
    Ny int64
    LocalColourPrecision int64
    Colour []AttributesColour
}
