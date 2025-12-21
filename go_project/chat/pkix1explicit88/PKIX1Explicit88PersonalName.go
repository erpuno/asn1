package pkix1explicit88

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type PKIX1Explicit88PersonalName struct {
    Surname string `asn1:"tag:0"`
    GivenName string `asn1:"optional,tag:1"`
    Initials string `asn1:"optional,tag:2"`
    GenerationQualifier string `asn1:"optional,tag:3"`
}
