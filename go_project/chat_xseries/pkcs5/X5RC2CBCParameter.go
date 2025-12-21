package pkcs5

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X5RC2CBCParameter struct {
    Rc2ParameterVersion int64 `asn1:"optional"`
    Iv []byte
}
