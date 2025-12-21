package dstu

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DSTU4145Params struct {
    Definition asn1.RawValue
    Dke []byte `asn1:"optional"`
}
