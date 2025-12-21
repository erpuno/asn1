package chat

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type CHATFileDesc struct {
    Id []byte
    Mime []byte
    Payload asn1.RawValue
    Parentid []byte
    Data []CHATFeature
}
