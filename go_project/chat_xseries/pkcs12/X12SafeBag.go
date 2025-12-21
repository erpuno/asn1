package pkcs12

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X12SafeBag struct {
    BagId asn1.ObjectIdentifier
    BagValue asn1.RawValue `asn1:"tag:0,explicit"`
    BagAttributes []X12PKCS12Attribute `asn1:"optional,set"`
}
