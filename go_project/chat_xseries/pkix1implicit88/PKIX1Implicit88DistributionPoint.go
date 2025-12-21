package pkix1implicit88

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type PKIX1Implicit88DistributionPoint struct {
    DistributionPoint PKIX1Implicit88DistributionPointName `asn1:"optional,tag:0"`
    Reasons PKIX1Implicit88ReasonFlags `asn1:"optional,tag:1"`
    CRLIssuer asn1.RawValue `asn1:"optional,tag:2"`
}
