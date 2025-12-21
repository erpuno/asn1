package pkix1explicit2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009CertificateList struct {
    ToBeSigned X2009CertificateListToBeSigned
    AlgorithmIdentifier asn1.RawValue
    Encrypted asn1.BitString
}
