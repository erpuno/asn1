package isostandard9541fontattributeset

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SETPAdjust struct {
    IsoStandard9541Pean SETGlobalName `asn1:"tag:0"`
    PAdjustPropertyList SETPAdjustProperties `asn1:"tag:1"`
}
