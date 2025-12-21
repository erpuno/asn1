package locationexpressions

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type ExpressionsCountersType struct {
    Start int64 `asn1:"optional,tag:0"`
    End int64 `asn1:"optional,tag:1"`
}
