package isostandard9541fontattributeset

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SETSectors struct {
    IsoStandard9541Sector []SETSector `asn1:"optional,tag:0"`
    NonIsoProperties SETPropertyList `asn1:"optional,set,tag:1"`
}
