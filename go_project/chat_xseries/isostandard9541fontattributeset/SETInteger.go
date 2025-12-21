package isostandard9541fontattributeset

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SETInteger int

const (
    SETIntegerFirst SETInteger = -2147483648
    SETIntegerLast SETInteger = 2147483647
)

