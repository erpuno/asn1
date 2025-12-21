package cryptographicmessagesyntax2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009OtherRevocationInfoFormat struct {
    OtherRevInfoFormat asn1.ObjectIdentifier
    OtherRevInfo asn1.RawValue
}
