package kep

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type KEPPKIStatus int

const (
    KEPPKIStatusAccepted KEPPKIStatus = 0
    KEPPKIStatusGrantedWithMods KEPPKIStatus = 1
    KEPPKIStatusRejection KEPPKIStatus = 2
    KEPPKIStatusWaiting KEPPKIStatus = 3
    KEPPKIStatusRevocationWarning KEPPKIStatus = 4
    KEPPKIStatusRevocationNotification KEPPKIStatus = 5
    KEPPKIStatusKeyUpdateWarning KEPPKIStatus = 6
)

