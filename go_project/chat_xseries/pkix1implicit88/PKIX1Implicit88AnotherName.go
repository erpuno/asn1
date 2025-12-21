package pkix1implicit88

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type PKIX1Implicit88AnotherName struct {
    TypeId asn1.ObjectIdentifier
    Value asn1.RawValue `asn1:"tag:0,explicit"`
}
