package kep

import (
    "encoding/asn1"
    "time"
    "tobirama/chat/x500"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type KEPIssuerAndSerialNumber struct {
    Issuer x500.InformationFrameworkName
    SerialNumber int64
}
