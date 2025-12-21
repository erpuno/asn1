package ldap

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type LDAPSubstringFilter struct {
    Type LDAPAttributeDescription
    Substrings []asn1.RawValue
}
