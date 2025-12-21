package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type InformationFrameworkResultAttribute struct {
    AttributeType asn1.ObjectIdentifier
    OutputValues asn1.RawValue `asn1:"optional"`
    Contexts []InformationFrameworkContextProfile `asn1:"optional,tag:0"`
}
