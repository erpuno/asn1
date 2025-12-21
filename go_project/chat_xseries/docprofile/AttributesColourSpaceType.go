package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesColourSpaceType int

const (
    AttributesColourSpaceTypeRgb AttributesColourSpaceType = 0
    AttributesColourSpaceTypeCmyk AttributesColourSpaceType = 1
    AttributesColourSpaceTypeCmy AttributesColourSpaceType = 2
    AttributesColourSpaceTypeCieluv AttributesColourSpaceType = 3
    AttributesColourSpaceTypeCielab AttributesColourSpaceType = 4
)

