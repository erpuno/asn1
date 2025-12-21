package ldap

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type LDAPAttribute struct {
    Type asn1.ObjectIdentifier
    Values []asn1.RawValue `asn1:"set"`
}
