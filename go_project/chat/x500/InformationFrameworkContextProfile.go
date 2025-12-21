package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type InformationFrameworkContextProfile struct {
    ContextType asn1.ObjectIdentifier
    ContextValue []asn1.RawValue `asn1:"optional"`
}
