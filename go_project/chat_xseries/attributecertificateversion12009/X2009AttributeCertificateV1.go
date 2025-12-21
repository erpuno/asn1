package attributecertificateversion12009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009AttributeCertificateV1 struct {
    ToBeSigned X2009AttributeCertificateV1ToBeSigned
    AlgorithmIdentifier asn1.RawValue
    Encrypted asn1.BitString
}
