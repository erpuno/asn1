package locationexpressions

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type ExpressionsStartEndObjectLocator struct {
    Object ExpressionsObjectLocator `asn1:"tag:0"`
    NotIncluded bool `asn1:"tag:1"`
}
