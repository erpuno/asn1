package ocsp

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/pkix1explicit88"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type OCSPSingleResponse struct {
    CertID OCSPCertID
    CertStatus OCSPCertStatus
    ThisUpdate time.Time
    NextUpdate time.Time `asn1:"optional,tag:0,explicit"`
    SingleExtensions pkix1explicit88.PKIX1Explicit88Extensions `asn1:"optional,tag:1,explicit"`
}
