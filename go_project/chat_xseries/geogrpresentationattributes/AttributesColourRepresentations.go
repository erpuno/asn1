package geogrpresentationattributes

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesColourRepresentations struct {
    BackgroundColour AttributesRGB `asn1:"optional,tag:0"`
    ColourTableSpecification []asn1.RawValue `asn1:"optional,tag:1"`
}
