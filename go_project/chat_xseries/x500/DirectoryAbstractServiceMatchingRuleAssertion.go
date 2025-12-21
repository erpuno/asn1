package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DirectoryAbstractServiceMatchingRuleAssertion struct {
    MatchingRule []asn1.ObjectIdentifier `asn1:"set,tag:1"`
    Type asn1.ObjectIdentifier `asn1:"optional,tag:2"`
    MatchValue asn1.RawValue `asn1:"tag:3"`
    DnAttributes bool `asn1:"tag:4"`
}
