package characterpresentationattributes

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesOneOfFourAngles int

const (
    AttributesOneOfFourAnglesD0 AttributesOneOfFourAngles = 0
    AttributesOneOfFourAnglesD90 AttributesOneOfFourAngles = 1
    AttributesOneOfFourAnglesD180 AttributesOneOfFourAngles = 2
    AttributesOneOfFourAnglesD270 AttributesOneOfFourAngles = 3
)

