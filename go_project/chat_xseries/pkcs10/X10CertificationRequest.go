package pkcs10

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X10CertificationRequest struct {
    CertificationRequestInfo X10CertificationRequestInfo
    SignatureAlgorithm asn1.RawValue
    Signature asn1.BitString
}
