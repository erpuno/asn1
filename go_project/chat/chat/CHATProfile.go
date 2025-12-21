package chat

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type CHATProfile struct {
    Nickname []byte
    Phone []byte
    Session []byte
    Chats []CHATContact
    Contacts []CHATContact
    Keys [][]byte
    Servers []CHATServer
    Settings []CHATFeature
    Update int64
    Status int64
    Roster CHATRoster
}
