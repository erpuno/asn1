package kep

import (
    "encoding/asn1"
    "time"
    "tobirama/chat/x500"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type KEPCertID struct {
    HashAlgorithm asn1.RawValue
    IssuerNameHash []byte
    IssuerKeyHash []byte
    SerialNumber x500.AuthenticationFrameworkCertificateSerialNumber
}
