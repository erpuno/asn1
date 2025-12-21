package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesColourCharacteristics struct {
    ColourSpacesPresent []asn1.RawValue `asn1:"tag:0"`
    ColourModesPresent AttributesColourModesPresent `asn1:"tag:1"`
    MinimumColourTolerance AttributesColourTolerance `asn1:"optional,tag:2"`
    MaximumColourTableLength int64 `asn1:"optional,tag:3"`
    MaximumRgbLutLength int64 `asn1:"optional,tag:4"`
    MaximumCmyKGridSize int64 `asn1:"optional,tag:5"`
}
