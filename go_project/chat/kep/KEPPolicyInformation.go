package kep

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type KEPPolicyInformation struct {
    PolicyIdentifier KEPCertPolicyId
    PolicyQualifiers []KEPPolicyQualifierInfo `asn1:"optional"`
}
