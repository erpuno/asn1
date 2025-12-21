package chat

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type CHATPresenceType int

const (
    CHATPresenceTypeOffline CHATPresenceType = 1
    CHATPresenceTypeOnline CHATPresenceType = 2
)

