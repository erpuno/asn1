package pkix1explicit88

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type PKIX1Explicit88ExtensionAttribute struct {
    ExtensionAttributeType int64 `asn1:"tag:0"`
    ExtensionAttributeValue asn1.RawValue `asn1:"tag:1"`
}
