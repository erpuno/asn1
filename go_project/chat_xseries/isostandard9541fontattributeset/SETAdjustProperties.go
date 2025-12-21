package isostandard9541fontattributeset

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SETAdjustProperties struct {
    IsoStandard9541Cpea SETCPEAProperties `asn1:"optional,tag:0"`
    IsoStandard9541Sec SETSECProperties `asn1:"optional,tag:1"`
    NonIsoProperties SETPropertyList `asn1:"optional,set,tag:2"`
}
