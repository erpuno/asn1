package cryptographicmessagesyntax2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009ExtendedCertificate struct {
    ExtendedCertificateInfo X2009ExtendedCertificateInfo
    SignatureAlgorithm X2009SignatureAlgorithmIdentifier
    Signature X2009Signature
}
