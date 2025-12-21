package ldap

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type LDAPExtendedRequest struct {
    RequestName LDAPOID `asn1:"tag:0"`
    RequestValue []byte `asn1:"optional,tag:1"`
}
