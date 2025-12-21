package pkix1implicit88

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type PKIX1Implicit88PolicyQualifierInfo struct {
    PolicyQualifierId PKIX1Implicit88PolicyQualifierId
    Qualifier asn1.RawValue
}
