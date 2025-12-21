package isostandard9541fontattributeset

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SETLigature struct {
    IsoStandard9541Lgn SETGlobalName `asn1:"tag:0"`
    IsoStandard9541Lgsn []SETGlobalName `asn1:"tag:1"`
}
