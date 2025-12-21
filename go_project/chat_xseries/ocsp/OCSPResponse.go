package ocsp

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type OCSPResponse struct {
    ResponseStatus OCSPResponseStatus
    ResponseBytes OCSPResponseBytes `asn1:"optional,tag:0,explicit"`
}
