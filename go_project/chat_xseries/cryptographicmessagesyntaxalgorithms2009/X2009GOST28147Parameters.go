package cryptographicmessagesyntaxalgorithms2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009GOST28147Parameters struct {
    Iv []byte
    Dke []byte
}
