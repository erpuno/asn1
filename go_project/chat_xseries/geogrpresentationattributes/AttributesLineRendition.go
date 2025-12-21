package geogrpresentationattributes

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesLineRendition struct {
    LineWidthSpecificationMode AttributesSpecificationMode `asn1:"optional,tag:0"`
    LineBundleIndex int64 `asn1:"optional,tag:1"`
    LineType int64 `asn1:"optional,tag:2"`
    LineWidth AttributesScaledOrAbsolute `asn1:"optional,tag:3"`
    LineColour AttributesColour `asn1:"optional,tag:4"`
    LineAspectSourceFlags asn1.RawValue `asn1:"optional,tag:5"`
    LineBundleSpecifications []asn1.RawValue `asn1:"optional,tag:6"`
}
