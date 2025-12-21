package isostandard9541fontattributeset

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SETCode int

const (
    SETCodeFirst SETCode = 0
    SETCodeLast SETCode = 255
)

