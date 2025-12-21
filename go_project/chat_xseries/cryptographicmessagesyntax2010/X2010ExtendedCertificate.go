package cryptographicmessagesyntax2010

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2010ExtendedCertificate struct {
    ExtendedCertificateInfo X2010ExtendedCertificateInfo
    SignatureAlgorithm X2010SignatureAlgorithmIdentifier
    Signature X2010Signature
}
