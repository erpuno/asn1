package isostandard9541fontattributeset

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SETCPEAProperties struct {
    IsoStandard9541Ncpeaforwd SETCardinal `asn1:"tag:0"`
    IsoStandard9541Ncpeabackwd SETCardinal `asn1:"tag:1"`
    IsoStandard9541Cpeax []SETRelRational `asn1:"optional,tag:2"`
    IsoStandard9541Cpeay []SETRelRational `asn1:"optional,tag:3"`
    NonIsoProperties SETPropertyList `asn1:"optional,set,tag:4"`
}
