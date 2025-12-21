package geogrpresentationattributes

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesFilledAreaRendition struct {
    FillBundleIndex int64 `asn1:"optional,tag:1"`
    InteriorStyle int `asn1:"optional,tag:2"`
    FillColour AttributesColour `asn1:"optional,tag:3"`
    HatchIndex int64 `asn1:"optional,tag:4"`
    PatternIndex int64 `asn1:"optional,tag:5"`
    FillReferencePoint AttributesVDCPair `asn1:"optional,tag:6"`
    PatternSize asn1.RawValue `asn1:"optional,tag:7"`
    PatternTableSpecifications []AttributesPatternTableElement `asn1:"optional,tag:8"`
    FillAspectSourceFlags asn1.RawValue `asn1:"optional,tag:9"`
    FillBundleSpecifications asn1.RawValue `asn1:"optional,tag:10"`
}
