package cryptographicmessagesyntaxalgorithms2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009PBKDF2Params struct {
    Salt asn1.RawValue
    IterationCount int64
    KeyLength int64 `asn1:"optional"`
    Prf X2009PBKDF2PRFsAlgorithmIdentifier
}
