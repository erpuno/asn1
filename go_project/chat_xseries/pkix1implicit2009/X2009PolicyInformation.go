package pkix1implicit2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009PolicyInformation struct {
    PolicyIdentifier X2009CertPolicyId
    PolicyQualifiers []X2009PolicyQualifierInfo `asn1:"optional"`
}
