package cryptographicmessagesyntax2010

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2010Attribute struct {
    Type asn1.ObjectIdentifier
    Values []asn1.RawValue `asn1:"set"`
}
