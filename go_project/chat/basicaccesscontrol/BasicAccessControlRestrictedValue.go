package basicaccesscontrol

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type BasicAccessControlRestrictedValue struct {
    Type asn1.ObjectIdentifier
    ValuesIn asn1.ObjectIdentifier
}
