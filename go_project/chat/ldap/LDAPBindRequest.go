package ldap

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type LDAPBindRequest struct {
    Version int64
    Name LDAPDN
    Authentication LDAPAuthenticationChoice
}
