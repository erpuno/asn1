package pkcs7

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X7Attribute struct {
    Type asn1.ObjectIdentifier
    Values []asn1.RawValue `asn1:"set"`
}
