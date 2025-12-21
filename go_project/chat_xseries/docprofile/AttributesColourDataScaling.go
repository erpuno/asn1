package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesColourDataScaling struct {
    FirstComponent AttributesScaleAndOffset `asn1:"tag:0"`
    SecondComponent AttributesScaleAndOffset `asn1:"tag:1"`
    ThirdComponent AttributesScaleAndOffset `asn1:"tag:2"`
    FourthComponent AttributesScaleAndOffset `asn1:"optional,tag:3"`
}
