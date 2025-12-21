package pkixattributecertificate2009

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/pkix1implicit2009"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009RoleSyntax struct {
    RoleAuthority asn1.RawValue `asn1:"optional,tag:0"`
    RoleName pkix1implicit2009.X2009GeneralName `asn1:"tag:1"`
}
