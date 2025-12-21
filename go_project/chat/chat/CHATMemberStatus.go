package chat

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type CHATMemberStatus int

const (
    CHATMemberStatusAdmin CHATMemberStatus = 1
    CHATMemberStatusMember CHATMemberStatus = 2
    CHATMemberStatusRemoved CHATMemberStatus = 3
    CHATMemberStatusPatch CHATMemberStatus = 4
    CHATMemberStatusOwner CHATMemberStatus = 5
)

