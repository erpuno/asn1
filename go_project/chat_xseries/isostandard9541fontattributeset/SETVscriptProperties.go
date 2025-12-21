package isostandard9541fontattributeset

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SETVscriptProperties struct {
    IsoStandard9541Vsoffsetx SETRelRational `asn1:"optional,tag:0"`
    IsoStandard9541Vsoffsety SETRelRational `asn1:"optional,tag:1"`
    IsoStandard9541Vsscalex SETRational `asn1:"optional,tag:2"`
    IsoStandard9541Vsscaley SETRational `asn1:"optional,tag:3"`
    NonIsoProperties SETPropertyList `asn1:"optional,set,tag:4"`
}
