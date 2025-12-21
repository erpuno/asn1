package pkcs5

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X5RC5CBCParameters struct {
    Version int64
    Rounds int64
    BlockSizeInBits int64
    Iv []byte `asn1:"optional"`
}
