package geogrpresentationattributes

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesTransparencySpecification struct {
    Transparency AttributesOnOrOff `asn1:"optional,tag:0"`
    AuxiliaryColour AttributesColour `asn1:"optional,tag:1"`
}
