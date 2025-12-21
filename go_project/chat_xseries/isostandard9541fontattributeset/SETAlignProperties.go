package isostandard9541fontattributeset

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SETAlignProperties struct {
    IsoStandard9541Alignoffsetx SETRelRational `asn1:"optional,tag:0"`
    IsoStandard9541Alignoffsety SETRelRational `asn1:"optional,tag:1"`
    IsoStandard9541Alignscalex SETRational `asn1:"optional,tag:2"`
    IsoStandard9541Alignscaley SETRational `asn1:"optional,tag:3"`
    NonIsoProperties SETPropertyList `asn1:"optional,set,tag:4"`
}
