package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type InformationFrameworkMRSubstitution struct {
    Attribute asn1.ObjectIdentifier
    OldMatchingRule asn1.ObjectIdentifier `asn1:"optional,tag:0"`
    NewMatchingRule asn1.ObjectIdentifier `asn1:"optional,tag:1"`
}
