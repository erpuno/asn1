package kep

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type KEPESSCertIDv2 struct {
    HashAlgorithm asn1.RawValue
    CertHash KEPHash
    IssuerSerial asn1.RawValue
}
