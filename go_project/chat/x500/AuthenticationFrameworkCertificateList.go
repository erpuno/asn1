package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AuthenticationFrameworkCertificateList struct {
    ToBeSigned AuthenticationFrameworkCertificateListToBeSigned
    AlgorithmIdentifier asn1.RawValue
    Encrypted asn1.BitString
}
