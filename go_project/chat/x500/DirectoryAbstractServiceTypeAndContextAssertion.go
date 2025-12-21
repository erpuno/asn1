package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DirectoryAbstractServiceTypeAndContextAssertion struct {
    Type asn1.ObjectIdentifier
    ContextAssertions asn1.RawValue
}
