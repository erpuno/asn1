package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type InformationFrameworkChopSpecification struct {
    SpecificExclusions []asn1.RawValue `asn1:"optional,set,tag:1"`
    Minimum InformationFrameworkBaseDistance `asn1:"tag:2"`
    Maximum InformationFrameworkBaseDistance `asn1:"optional,tag:3"`
}
