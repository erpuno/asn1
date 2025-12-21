package locationexpressions

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type ExpressionsRegionLocator struct {
    Start ExpressionsStartEndObjectLocator `asn1:"tag:0"`
    End ExpressionsStartEndObjectLocator `asn1:"tag:1"`
}
