package geogrpresentationattributes

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesTransformationSpecification struct {
    VdcExtent AttributesRectangle `asn1:"optional,tag:0"`
    ClipRectangle AttributesRectangle `asn1:"optional,tag:1"`
    ClipIndicator AttributesOnOrOff `asn1:"optional,tag:2"`
}
