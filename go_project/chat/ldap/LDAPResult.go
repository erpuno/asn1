package ldap

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type LDAPResult struct {
    ResultCode int
    MatchedDN LDAPDN
    DiagnosticMessage LDAPString
    Referral LDAPReferral `asn1:"optional,tag:3"`
}
