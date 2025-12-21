package chat

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type CHATFriendship int

const (
    CHATFriendshipRequest CHATFriendship = 1
    CHATFriendshipConfirm CHATFriendship = 2
    CHATFriendshipUpdate CHATFriendship = 3
    CHATFriendshipIgnore CHATFriendship = 4
    CHATFriendshipBan CHATFriendship = 5
    CHATFriendshipUnban CHATFriendship = 6
)

