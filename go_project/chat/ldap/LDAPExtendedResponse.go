package ldap

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type LDAPExtendedResponse struct {
    ResponseName LDAPOID `asn1:"optional,tag:10"`
    ResponseValue []byte `asn1:"optional,tag:11"`
}
