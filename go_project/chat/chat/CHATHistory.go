package chat

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type CHATHistory struct {
    Nickname []byte
    Feed asn1.RawValue
    Size int64
    EntityId int64
    Data []CHATMessage
    Status CHATHistoryStatus
}
