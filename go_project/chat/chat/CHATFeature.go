package chat

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type CHATFeature struct {
    Id []byte
    Key []byte
    Value []byte
    Group []byte
}
