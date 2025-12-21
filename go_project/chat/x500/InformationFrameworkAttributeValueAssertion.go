package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type InformationFrameworkAttributeValueAssertion struct {
    Type asn1.ObjectIdentifier
    Assertion asn1.RawValue
    AssertedContexts asn1.RawValue `asn1:"optional"`
}
