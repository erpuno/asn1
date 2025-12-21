package characterpresentationattributes

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesOneOfTwoAngles int

const (
    AttributesOneOfTwoAnglesD90 AttributesOneOfTwoAngles = 1
    AttributesOneOfTwoAnglesD270 AttributesOneOfTwoAngles = 3
)

