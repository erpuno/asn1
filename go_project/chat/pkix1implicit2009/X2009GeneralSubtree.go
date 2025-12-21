package pkix1implicit2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009GeneralSubtree struct {
    Base X2009GeneralName
    Minimum X2009BaseDistance `asn1:"tag:0"`
    Maximum X2009BaseDistance `asn1:"optional,tag:1"`
}
