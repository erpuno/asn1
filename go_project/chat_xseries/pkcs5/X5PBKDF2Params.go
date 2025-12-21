package pkcs5

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X5PBKDF2Params struct {
    Salt asn1.RawValue
    IterationCount int64
    KeyLength int64 `asn1:"optional"`
    Prf asn1.RawValue
}
