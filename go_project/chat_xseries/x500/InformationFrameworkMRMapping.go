package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type InformationFrameworkMRMapping struct {
    Mapping []InformationFrameworkMapping `asn1:"optional,tag:0"`
    Substitution []InformationFrameworkMRSubstitution `asn1:"optional,tag:1"`
}
