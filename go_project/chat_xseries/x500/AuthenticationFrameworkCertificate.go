package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AuthenticationFrameworkCertificate struct {
    ToBeSigned AuthenticationFrameworkCertificateToBeSigned
    AlgorithmIdentifier asn1.RawValue
    Encrypted asn1.BitString
}
