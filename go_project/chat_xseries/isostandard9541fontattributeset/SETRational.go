package isostandard9541fontattributeset

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SETRational struct {
    Numerator int64 `asn1:"tag:0"`
    Denominator int64 `asn1:"optional,tag:1"`
}
