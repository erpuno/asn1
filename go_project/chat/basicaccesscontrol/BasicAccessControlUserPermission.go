package basicaccesscontrol

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type BasicAccessControlUserPermission struct {
    Precedence BasicAccessControlPrecedence `asn1:"optional"`
    ProtectedItems BasicAccessControlProtectedItems
    GrantsAndDenials BasicAccessControlGrantsAndDenials
}
