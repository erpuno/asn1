package ansix942

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X42DomainParameters struct {
    P int64
    G int64
    Q int64
    J int64 `asn1:"optional"`
    ValidationParms X42ValidationParms `asn1:"optional"`
}
