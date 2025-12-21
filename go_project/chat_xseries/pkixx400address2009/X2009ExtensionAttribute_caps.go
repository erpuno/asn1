package pkixx400address2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009ExtensionAttribute struct {
    ExtensionAttributeType asn1.ObjectIdentifier `asn1:"tag:0"`
    ExtensionAttributeValue asn1.RawValue `asn1:"tag:1"`
}
