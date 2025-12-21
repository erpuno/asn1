package ocsp

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/pkix1explicit88"
    "tobirama/chat_xseries/pkix1implicit88"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type OCSPTBSRequest struct {
    Version OCSPVersion `asn1:"tag:0,explicit"`
    RequestorName pkix1implicit88.PKIX1Implicit88GeneralName `asn1:"optional,tag:1,explicit"`
    RequestList []OCSPRequest
    RequestExtensions pkix1explicit88.PKIX1Explicit88Extensions `asn1:"optional,tag:2,explicit"`
}
