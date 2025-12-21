package basicaccesscontrol

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type BasicAccessControlAttributeTypeAndValue struct {
    Type asn1.ObjectIdentifier
    Value asn1.RawValue
}
