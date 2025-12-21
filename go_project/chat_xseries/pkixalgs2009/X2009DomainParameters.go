package pkixalgs2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009DomainParameters struct {
    P int64
    G int64
    Q int64
    J int64 `asn1:"optional"`
    ValidationParams X2009ValidationParams `asn1:"optional"`
}
