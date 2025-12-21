package extendedsecurityservices2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009ESSCertIDv2 struct {
    HashAlgorithm X2009HashAlgorithm
    CertHash X2009Hash
    IssuerSerial asn1.RawValue `asn1:"optional"`
}
