package pkix1implicit88

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type PKIX1Implicit88GeneralSubtree struct {
    Base PKIX1Implicit88GeneralName
    Minimum PKIX1Implicit88BaseDistance `asn1:"tag:0"`
    Maximum PKIX1Implicit88BaseDistance `asn1:"optional,tag:1"`
}
