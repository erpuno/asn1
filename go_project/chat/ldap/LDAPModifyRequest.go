package ldap

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type LDAPModifyRequest struct {
    Object LDAPDN
    Changes []asn1.RawValue
}
