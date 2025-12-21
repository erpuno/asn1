package rastergrpresentationattributes

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesClipping struct {
    FirstCoordinatePair AttributesCoordinatePair `asn1:"optional,tag:0"`
    SecondCoordinatePair AttributesCoordinatePair `asn1:"optional,tag:1"`
}
