package geogrpresentationattributes

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesTextRendition struct {
    FontList []asn1.RawValue `asn1:"optional,tag:0"`
    CharacterSetList asn1.RawValue `asn1:"optional,tag:1"`
    CharacterCodingAnnouncer int `asn1:"optional,tag:2"`
    TextBundleIndex int64 `asn1:"optional,tag:3"`
    TextFontIndex int64 `asn1:"optional,tag:4"`
    TextPrecision int `asn1:"optional,tag:5"`
    CharacterExpansionFactor float64 `asn1:"optional,tag:6"`
    CharacterSpacing float64 `asn1:"optional,tag:7"`
    TextColour AttributesColour `asn1:"optional,tag:8"`
    CharacterHeight AttributesVDCValue `asn1:"optional,tag:9"`
    CharacterOrientation asn1.RawValue `asn1:"optional,tag:10"`
    TextPath int `asn1:"optional,tag:11"`
    TextAlignment asn1.RawValue `asn1:"optional,tag:12"`
    CharacterSetIndex int64 `asn1:"optional,tag:13"`
    AlternateCharacterSetIndex int64 `asn1:"optional,tag:14"`
    TextAspectSourceFlags asn1.RawValue `asn1:"optional,tag:15"`
    TextBundleSpecifications []asn1.RawValue `asn1:"optional,tag:16"`
}
