package pkix1implicit88

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type PKIX1Implicit88PolicyConstraints struct {
    RequireExplicitPolicy PKIX1Implicit88SkipCerts `asn1:"optional,tag:0"`
    InhibitPolicyMapping PKIX1Implicit88SkipCerts `asn1:"optional,tag:1"`
}
