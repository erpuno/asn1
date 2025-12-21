package rastergrpresentationattributes

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesRasterGraphicsAttributes struct {
    PelPath AttributesOneOfFourAngles `asn1:"optional,tag:0"`
    LineProgression AttributesOneOfTwoAngles `asn1:"optional,tag:1"`
    PelTransmissionDensity AttributesPelTransmissionDensity `asn1:"optional,tag:2"`
    InitialOffset AttributesMeasurePair `asn1:"optional,tag:3"`
    Clipping AttributesClipping `asn1:"optional,tag:4"`
    PelSpacing AttributesPelSpacing `asn1:"optional,tag:5"`
    SpacingRatio AttributesSpacingRatio `asn1:"optional,tag:6"`
    ImageDimensions AttributesImageDimensions `asn1:"optional,tag:7"`
}
