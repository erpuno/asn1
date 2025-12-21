package isostandard9541fontattributeset

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SETScoreProperties struct {
    IsoStandard9541Scoreoffsetx SETRelRational `asn1:"optional,tag:0"`
    IsoStandard9541Scoreoffsety SETRelRational `asn1:"optional,tag:1"`
    IsoStandard9541Scorethick SETRelRational `asn1:"optional,tag:2"`
    NonIsoProperties SETPropertyList `asn1:"optional,set,tag:3"`
}
