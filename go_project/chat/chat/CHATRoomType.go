package chat

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type CHATRoomType int

const (
    CHATRoomTypeGroup CHATRoomType = 1
    CHATRoomTypeChannel CHATRoomType = 2
    CHATRoomTypeCall CHATRoomType = 3
)

