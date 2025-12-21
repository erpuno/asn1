package kep

import (
    "encoding/asn1"
    "time"
    "tobirama/chat/x500"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type KEPSingleResponse struct {
    CertID KEPCertID
    CertStatus KEPCertStatus
    ThisUpdate time.Time
    NextUpdate time.Time `asn1:"optional,tag:0,explicit"`
    SingleExtensions x500.AuthenticationFrameworkExtensions `asn1:"optional,tag:1,explicit"`
}
