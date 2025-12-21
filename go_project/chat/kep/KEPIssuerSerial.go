package kep

import (
    "encoding/asn1"
    "time"
    "tobirama/chat/x500"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type KEPIssuerSerial struct {
    Issuer asn1.RawValue
    SerialNumber x500.AuthenticationFrameworkCertificateSerialNumber
}
