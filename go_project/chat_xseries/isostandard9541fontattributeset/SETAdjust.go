package isostandard9541fontattributeset

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SETAdjust struct {
    IsoStandard9541Escadjname SETGlobalName `asn1:"tag:0"`
    AdjustProperties SETAdjustProperties `asn1:"tag:1"`
}
