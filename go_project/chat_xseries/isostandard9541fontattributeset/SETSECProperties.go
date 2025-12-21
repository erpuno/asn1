package isostandard9541fontattributeset

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SETSECProperties struct {
    IsoStandard9541Secx []asn1.RawValue `asn1:"optional,tag:0"`
    IsoStandard9541Secy []asn1.RawValue `asn1:"optional,tag:1"`
    NonIsoProperties SETPropertyList `asn1:"optional,set,tag:2"`
}
