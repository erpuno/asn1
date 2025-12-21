package kep

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type KEPPKIStatusInfo struct {
    Status KEPPKIStatus
    StatusString KEPPKIFreeText `asn1:"optional"`
    FailInfo KEPPKIFailureInfo `asn1:"optional"`
}
