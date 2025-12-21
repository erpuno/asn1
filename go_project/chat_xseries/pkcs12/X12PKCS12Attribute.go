package pkcs12

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X12PKCS12Attribute struct {
    AttrId asn1.ObjectIdentifier
    AttrValues []asn1.RawValue `asn1:"set"`
}
