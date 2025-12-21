package chat

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type CHATRoster struct {
    Id []byte
    Nickname []byte
    Update int64
    Contacts []CHATContact
    Topics []CHATRoom
    Status CHATRosterStatus
}
