package kep

import (
    "encoding/asn1"
    "time"
    "tobirama/chat/x500"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type KEPRevokedInfo struct {
    RevocationTime time.Time
    RevocationReason x500.CertificateExtensionsCRLReason `asn1:"optional,tag:0,explicit"`
}
