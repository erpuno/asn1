package ocsp

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/pkix1explicit88"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type OCSPResponseData struct {
    Version OCSPVersion `asn1:"tag:0,explicit"`
    ResponderID OCSPResponderID
    ProducedAt time.Time
    Responses []OCSPSingleResponse
    ResponseExtensions pkix1explicit88.PKIX1Explicit88Extensions `asn1:"optional,tag:1,explicit"`
}
