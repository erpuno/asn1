package pkix1implicit2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009PolicyConstraints struct {
    RequireExplicitPolicy X2009SkipCerts `asn1:"optional,tag:0"`
    InhibitPolicyMapping X2009SkipCerts `asn1:"optional,tag:1"`
}
