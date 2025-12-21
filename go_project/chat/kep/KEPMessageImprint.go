package kep

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type KEPMessageImprint struct {
    HashAlgorithm asn1.RawValue
    HashedMessage []byte
}
