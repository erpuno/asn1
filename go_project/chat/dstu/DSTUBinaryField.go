package dstu

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DSTUBinaryField struct {
    M int64
    P asn1.RawValue `asn1:"optional"`
}
