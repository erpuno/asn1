package basicaccesscontrol

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type BasicAccessControlACIItem struct {
    IdentificationTag asn1.RawValue
    Precedence BasicAccessControlPrecedence
    AuthenticationLevel BasicAccessControlAuthenticationLevel
    ItemOrUserFirst asn1.RawValue
}
