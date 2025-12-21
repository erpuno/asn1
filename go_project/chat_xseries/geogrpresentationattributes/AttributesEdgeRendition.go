package geogrpresentationattributes

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesEdgeRendition struct {
    EdgeWidthSpecMode AttributesSpecificationMode `asn1:"optional,tag:0"`
    EdgeVisibility AttributesOnOrOff `asn1:"optional,tag:1"`
    EdgeBundleIndex int64 `asn1:"optional,tag:2"`
    EdgeType int64 `asn1:"optional,tag:3"`
    EdgeWidth AttributesScaledOrAbsolute `asn1:"optional,tag:4"`
    EdgeColour AttributesColour `asn1:"optional,tag:5"`
    EdgeAspectSourceFlags asn1.RawValue `asn1:"optional,tag:6"`
    EdgeBundleSpecifications []asn1.RawValue `asn1:"optional,tag:7"`
}
