package chat

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type CHATMessageStatus int

const (
    CHATMessageStatusAsync CHATMessageStatus = 1
    CHATMessageStatusDelete CHATMessageStatus = 2
    CHATMessageStatusClear CHATMessageStatus = 3
    CHATMessageStatusUpdate CHATMessageStatus = 4
    CHATMessageStatusEdit CHATMessageStatus = 5
)

