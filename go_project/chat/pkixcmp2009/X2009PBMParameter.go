package pkixcmp2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009PBMParameter struct {
    Salt []byte
    Owf asn1.RawValue
    IterationCount int64
    Mac asn1.RawValue
}
