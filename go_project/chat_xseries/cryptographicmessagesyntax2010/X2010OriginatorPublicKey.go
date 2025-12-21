package cryptographicmessagesyntax2010

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2010OriginatorPublicKey struct {
    Algorithm asn1.RawValue
    PublicKey asn1.BitString
}
