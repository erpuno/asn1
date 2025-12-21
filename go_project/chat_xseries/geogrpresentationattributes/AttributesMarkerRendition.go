package geogrpresentationattributes

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesMarkerRendition struct {
    MarkerSizeSpecificationMode AttributesSpecificationMode `asn1:"optional,tag:0"`
    MarkerBundleIndex int64 `asn1:"optional,tag:1"`
    MarkerType int64 `asn1:"optional,tag:2"`
    MarkerSize AttributesScaledOrAbsolute `asn1:"optional,tag:3"`
    MarkerColour AttributesColour `asn1:"optional,tag:4"`
    MarkerAspectSourceFlags asn1.RawValue `asn1:"optional,tag:5"`
    MarkerBundleSpecifications []asn1.RawValue `asn1:"optional,tag:6"`
}
