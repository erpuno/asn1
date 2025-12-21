package chat

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type CHATMessage struct {
    No int64
    Headers [][]byte
    Body CHATProtocol
}
