package pkix1implicit2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009DistributionPoint struct {
    DistributionPoint X2009DistributionPointName `asn1:"optional,tag:0"`
    Reasons X2009ReasonFlags `asn1:"optional,tag:1"`
    CRLIssuer asn1.RawValue `asn1:"optional,tag:2"`
}
