package isostandard9541fontattributeset

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SETPAdjustProperties struct {
    IsoStandard9541Peax []asn1.RawValue `asn1:"optional,tag:0"`
    IsoStandard9541Peay []asn1.RawValue `asn1:"optional,tag:1"`
    IsoStandard9541Speaforwdx []SETRelRational `asn1:"optional,tag:2"`
    IsoStandard9541Speaforwdy []SETRelRational `asn1:"optional,tag:3"`
    IsoStandard9541Speabackwdx []SETRelRational `asn1:"optional,tag:4"`
    IsoStandard9541Speabackwdy []SETRelRational `asn1:"optional,tag:5"`
    NonIsoProperties SETPropertyList `asn1:"optional,set,tag:6"`
}
