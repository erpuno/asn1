package chat

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type CHATRoom struct {
    Id []byte
    Name []byte
    Links [][]byte
    Description []byte
    Settings []CHATFeature
    Members []CHATMember
    Admins []CHATMember
    Data []CHATFileDesc
    Type CHATRoomType
    Tos []byte
    TosUpdate int64
    Unread int64
    Mentions []int64
    LastMsg CHATMessage
    Update int64
    Created int64
    Status CHATRoomStatus
}
