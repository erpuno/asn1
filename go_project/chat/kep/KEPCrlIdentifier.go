package kep

import (
    "encoding/asn1"
    "time"
    "tobirama/chat/x500"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type KEPCrlIdentifier struct {
    Crlissuer x500.InformationFrameworkName
    CrlIssuedTime time.Time
    CrlNumber int64 `asn1:"optional"`
}
