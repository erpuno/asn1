package cryptographicmessagesyntax2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009ContentInfo struct {
    ContentType asn1.ObjectIdentifier
    Content asn1.RawValue `asn1:"tag:0,explicit"`
}
