package pkix1implicit88

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type PKIX1Implicit88PolicyInformation struct {
    PolicyIdentifier PKIX1Implicit88CertPolicyId
    PolicyQualifiers []PKIX1Implicit88PolicyQualifierInfo `asn1:"optional"`
}
