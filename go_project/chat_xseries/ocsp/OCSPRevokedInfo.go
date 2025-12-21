package ocsp

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/pkix1implicit88"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type OCSPRevokedInfo struct {
    RevocationTime time.Time
    RevocationReason pkix1implicit88.PKIX1Implicit88CRLReason `asn1:"optional,tag:0,explicit"`
}
