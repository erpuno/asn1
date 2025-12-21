package isostandard9541fontattributeset

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SETGlyphComplement struct {
    IsoStandard9541Numglyphs SETCardinal `asn1:"optional,tag:0"`
    IsoStandard9541Incglyphcols []SETGlobalName `asn1:"optional,set,tag:1"`
    IsoStandard9541Excglyphcols []SETGlobalName `asn1:"optional,set,tag:2"`
    IsoStandard9541Incglyphs []SETGlobalName `asn1:"optional,set,tag:3"`
    IsoStandard9541Excglyphs []SETGlobalName `asn1:"optional,set,tag:4"`
    NonIsoProperties SETPropertyList `asn1:"optional,set,tag:5"`
}
