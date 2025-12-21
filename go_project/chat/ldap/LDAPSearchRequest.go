package ldap

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type LDAPSearchRequest struct {
    BaseObject LDAPDN
    Scope int
    DerefAliases int
    SizeLimit int64
    TimeLimit int64
    TypesOnly bool
    Filter LDAPFilter
    Attributes LDAPAttributeSelection
}
