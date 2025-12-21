package pkixattributecertificate2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009AttributeCertificate struct {
    ToBeSigned X2009AttributeCertificateToBeSigned
    AlgorithmIdentifier asn1.RawValue
    Encrypted asn1.BitString
}
