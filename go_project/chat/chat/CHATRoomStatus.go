package chat

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type CHATRoomStatus int

const (
    CHATRoomStatusCreate CHATRoomStatus = 1
    CHATRoomStatusLeave CHATRoomStatus = 2
    CHATRoomStatusAdd CHATRoomStatus = 3
    CHATRoomStatusRemove CHATRoomStatus = 4
    CHATRoomStatusRemoved CHATRoomStatus = 5
    CHATRoomStatusJoin CHATRoomStatus = 6
    CHATRoomStatusJoined CHATRoomStatus = 7
    CHATRoomStatusInfo CHATRoomStatus = 8
    CHATRoomStatusPatch CHATRoomStatus = 9
    CHATRoomStatusGet CHATRoomStatus = 10
    CHATRoomStatusDelete CHATRoomStatus = 11
    CHATRoomStatusLastMsg CHATRoomStatus = 12
    CHATRoomStatusMute CHATRoomStatus = 13
    CHATRoomStatusUnmute CHATRoomStatus = 14
)

