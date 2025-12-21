package pkix1explicit2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009SubjectPublicKeyInfo struct {
    Algorithm asn1.RawValue
    SubjectPublicKey asn1.BitString
}
