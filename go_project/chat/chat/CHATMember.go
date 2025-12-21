package chat

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type CHATMember struct {
    Id int64
    FeedId asn1.RawValue
    Feeds [][]byte
    PhoneId []byte
    Avatar []byte
    Names [][]byte
    Surnames [][]byte
    Alias []byte
    Update int64
    Settings []CHATFeature
    Services []CHATService
    Presence CHATPresenceType
    Status CHATMemberStatus
}
