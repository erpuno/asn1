package ocsp

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/pkix1explicit88"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type OCSPRequest struct {
    ReqCert OCSPCertID
    SingleRequestExtensions pkix1explicit88.PKIX1Explicit88Extensions `asn1:"optional,tag:0,explicit"`
}
