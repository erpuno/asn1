package pkcs12

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X12CertBag struct {
    CertId asn1.ObjectIdentifier
    CertValue asn1.RawValue `asn1:"tag:0,explicit"`
}
