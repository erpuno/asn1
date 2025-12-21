package isostandard9541fontattributeset

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SETWritingMode struct {
    IsoStandard9541Wrmodename SETGlobalName `asn1:"tag:0"`
    WrmodeProperties SETModalProperties `asn1:"tag:1"`
}
