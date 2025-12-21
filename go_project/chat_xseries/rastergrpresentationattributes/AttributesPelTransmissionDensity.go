package rastergrpresentationattributes

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesPelTransmissionDensity int

const (
    AttributesPelTransmissionDensityP5 AttributesPelTransmissionDensity = 2
    AttributesPelTransmissionDensityP4 AttributesPelTransmissionDensity = 3
    AttributesPelTransmissionDensityP3 AttributesPelTransmissionDensity = 4
    AttributesPelTransmissionDensityP2 AttributesPelTransmissionDensity = 5
    AttributesPelTransmissionDensityP1 AttributesPelTransmissionDensity = 6
    AttributesPelTransmissionDensityColourGreyScaleP12 AttributesPelTransmissionDensity = 10
    AttributesPelTransmissionDensityColourGreyScaleP6 AttributesPelTransmissionDensity = 11
    AttributesPelTransmissionDensityColourGreyScaleP4 AttributesPelTransmissionDensity = 13
    AttributesPelTransmissionDensityColourGreyScaleP3 AttributesPelTransmissionDensity = 14
    AttributesPelTransmissionDensityColourGreyScaleP2 AttributesPelTransmissionDensity = 15
    AttributesPelTransmissionDensityColourGreyScaleP1 AttributesPelTransmissionDensity = 16
    AttributesPelTransmissionDensityP6 AttributesPelTransmissionDensity = 1
)

