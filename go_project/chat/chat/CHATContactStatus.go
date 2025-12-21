package chat

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type CHATContactStatus int

const (
    CHATContactStatusRequest CHATContactStatus = 1
    CHATContactStatusAuthorization CHATContactStatus = 2
    CHATContactStatusIgnore CHATContactStatus = 3
    CHATContactStatusIntern CHATContactStatus = 4
    CHATContactStatusFriend CHATContactStatus = 5
    CHATContactStatusLastMsg CHATContactStatus = 6
    CHATContactStatusBan CHATContactStatus = 7
    CHATContactStatusBanned CHATContactStatus = 8
    CHATContactStatusDeleted CHATContactStatus = 9
    CHATContactStatusNonexised CHATContactStatus = 10
)

