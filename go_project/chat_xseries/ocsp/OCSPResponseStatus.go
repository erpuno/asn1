package ocsp

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type OCSPResponseStatus int

const (
    OCSPResponseStatusSuccessful OCSPResponseStatus = 0
    OCSPResponseStatusMalformedRequest OCSPResponseStatus = 1
    OCSPResponseStatusInternalError OCSPResponseStatus = 2
    OCSPResponseStatusTryLater OCSPResponseStatus = 3
    OCSPResponseStatusSigRequired OCSPResponseStatus = 5
    OCSPResponseStatusUnauthorized OCSPResponseStatus = 6
)

