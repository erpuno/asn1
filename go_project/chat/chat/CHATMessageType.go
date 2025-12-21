package chat

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type CHATMessageType int

const (
    CHATMessageTypeSys CHATMessageType = 1
    CHATMessageTypeReply CHATMessageType = 2
    CHATMessageTypeForward CHATMessageType = 3
    CHATMessageTypeRead CHATMessageType = 4
    CHATMessageTypeEdited CHATMessageType = 5
)

