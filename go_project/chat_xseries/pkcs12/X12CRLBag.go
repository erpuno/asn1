package pkcs12

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X12CRLBag struct {
    CrlId asn1.ObjectIdentifier
    CrlValue asn1.RawValue `asn1:"tag:0,explicit"`
}
