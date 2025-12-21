package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type InformationFrameworkContextAssertion struct {
    ContextType asn1.ObjectIdentifier
    ContextValues []asn1.RawValue `asn1:"set"`
}
