package chat

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type CHATHistoryStatus int

const (
    CHATHistoryStatusUpdated CHATHistoryStatus = 1
    CHATHistoryStatusGet CHATHistoryStatus = 2
    CHATHistoryStatusUpdate CHATHistoryStatus = 3
    CHATHistoryStatusLastLoaded CHATHistoryStatus = 4
    CHATHistoryStatusLastMsg CHATHistoryStatus = 5
    CHATHistoryStatusGetReply CHATHistoryStatus = 6
    CHATHistoryStatusDoubleGet CHATHistoryStatus = 7
    CHATHistoryStatusDelete CHATHistoryStatus = 8
    CHATHistoryStatusImage CHATHistoryStatus = 9
    CHATHistoryStatusVideo CHATHistoryStatus = 10
    CHATHistoryStatusFile CHATHistoryStatus = 11
    CHATHistoryStatusLink CHATHistoryStatus = 12
    CHATHistoryStatusAudio CHATHistoryStatus = 13
    CHATHistoryStatusContact CHATHistoryStatus = 14
    CHATHistoryStatusLocation CHATHistoryStatus = 15
    CHATHistoryStatusText CHATHistoryStatus = 16
)

