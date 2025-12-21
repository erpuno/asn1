package dstu

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DSTUECBinary struct {
    Version int64 `asn1:"tag:0,explicit"`
    F DSTUBinaryField
    A int64
    B []byte
    N int64
    Bp []byte
}
