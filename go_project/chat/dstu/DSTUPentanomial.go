package dstu

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DSTUPentanomial struct {
    K int64
    J int64
    L int64
}
