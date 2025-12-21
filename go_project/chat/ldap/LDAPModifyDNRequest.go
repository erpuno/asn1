package ldap

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type LDAPModifyDNRequest struct {
    Entry LDAPDN
    Newrdn LDAPRelativeLDAPDN
    Deleteoldrdn bool
    NewSuperior LDAPDN `asn1:"optional,tag:0"`
}
