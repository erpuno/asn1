package ldap

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type LDAPControl struct {
    ControlType LDAPOID
    Criticality bool
    ControlValue []byte `asn1:"optional"`
}
