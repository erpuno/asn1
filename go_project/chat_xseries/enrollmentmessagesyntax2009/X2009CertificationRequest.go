package enrollmentmessagesyntax2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009CertificationRequest struct {
    CertificationRequestInfo asn1.RawValue
    SignatureAlgorithm asn1.RawValue
    Signature asn1.BitString
}
