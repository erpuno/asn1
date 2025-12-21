package pkix1explicit88

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type PKIX1Explicit88TeletexPersonalName struct {
    Surname asn1.RawValue `asn1:"tag:0"`
    GivenName asn1.RawValue `asn1:"optional,tag:1"`
    Initials asn1.RawValue `asn1:"optional,tag:2"`
    GenerationQualifier asn1.RawValue `asn1:"optional,tag:3"`
}
