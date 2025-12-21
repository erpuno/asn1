package ldap

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type LDAPMatchingRuleAssertion struct {
    MatchingRule LDAPMatchingRuleId `asn1:"optional,tag:1"`
    Type LDAPAttributeDescription `asn1:"optional,tag:2"`
    MatchValue LDAPAssertionValue `asn1:"tag:3"`
    DnAttributes bool `asn1:"tag:4"`
}
