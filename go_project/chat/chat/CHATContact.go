package chat

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type CHATContact struct {
    Nickname []byte
    Avatar []byte
    Names [][]byte
    PhoneId []byte
    Surnames [][]byte
    LastMsg CHATMessage
    Presence CHATPresenceType
    Update int64
    Created int64
    Settings []CHATFeature
    Services []CHATService
    Status CHATContactStatus
}
