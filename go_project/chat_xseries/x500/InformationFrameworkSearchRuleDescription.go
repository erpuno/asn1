package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type InformationFrameworkSearchRuleDescription struct {
    Name []asn1.RawValue `asn1:"optional,set,tag:28"`
    Description asn1.RawValue `asn1:"optional,tag:29"`
    Obsolete bool `asn1:"tag:30"`
}
