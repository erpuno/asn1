package pkixx400address2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009PersonalName struct {
    Surname string `asn1:"tag:0"`
    GivenName string `asn1:"optional,tag:1"`
    Initials string `asn1:"optional,tag:2"`
    GenerationQualifier string `asn1:"optional,tag:3"`
}
