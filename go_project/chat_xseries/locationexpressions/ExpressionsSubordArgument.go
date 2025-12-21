package locationexpressions

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type ExpressionsSubordArgument struct {
    Object ExpressionsObjectLocator `asn1:"tag:0"`
    Counters ExpressionsCountersType `asn1:"optional,tag:1"`
}
