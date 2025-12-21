package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesDirectColour struct {
    ColourSpaceId int64 `asn1:"optional,tag:0"`
    ColourSpecification AttributesColourSpecification `asn1:"optional,tag:1"`
    ColourTolerance AttributesColourTolerance `asn1:"optional,tag:2"`
}
