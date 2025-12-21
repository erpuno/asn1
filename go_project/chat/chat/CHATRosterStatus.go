package chat

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type CHATRosterStatus int

const (
    CHATRosterStatusGet CHATRosterStatus = 1
    CHATRosterStatusCreate CHATRosterStatus = 2
    CHATRosterStatusDel CHATRosterStatus = 3
    CHATRosterStatusRemove CHATRosterStatus = 4
    CHATRosterStatusNick CHATRosterStatus = 5
    CHATRosterStatusSearch CHATRosterStatus = 6
    CHATRosterStatusContact CHATRosterStatus = 7
    CHATRosterStatusAdd CHATRosterStatus = 8
    CHATRosterStatusUpdate CHATRosterStatus = 9
    CHATRosterStatusList CHATRosterStatus = 10
    CHATRosterStatusPatch CHATRosterStatus = 11
    CHATRosterStatusLastMsg CHATRosterStatus = 12
)

