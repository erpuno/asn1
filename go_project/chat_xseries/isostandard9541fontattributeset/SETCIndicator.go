package isostandard9541fontattributeset

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SETCIndicator struct {
    CForward SETCardinal `asn1:"tag:0"`
    CBackward SETCardinal `asn1:"tag:1"`
}
