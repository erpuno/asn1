package kep

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type KEPSigPolicyQualifierInfo struct {
    SigPolicyQualifierId KEPSigPolicyQualifierId
    SigQualifier asn1.RawValue
}
