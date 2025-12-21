package kep

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type KEPCMSVersion int

const (
    KEPCMSVersionV0 KEPCMSVersion = 0
    KEPCMSVersionV1 KEPCMSVersion = 1
    KEPCMSVersionV2 KEPCMSVersion = 2
    KEPCMSVersionV3 KEPCMSVersion = 3
    KEPCMSVersionV4 KEPCMSVersion = 4
    KEPCMSVersionV5 KEPCMSVersion = 5
)

