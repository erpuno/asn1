package kep

import (
    "encoding/asn1"
    "time"
    "tobirama/chat/pkixcmp2009"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type KEPTimeStampResp struct {
    Status pkixcmp2009.X2009PKIStatusInfo
    TimeStampToken KEPTimeStampToken `asn1:"optional"`
}
