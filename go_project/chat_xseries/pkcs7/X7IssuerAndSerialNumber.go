package pkcs7

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/x500"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X7IssuerAndSerialNumber struct {
    Issuer x500.InformationFrameworkName
    SerialNumber x500.AuthenticationFrameworkCertificateSerialNumber
}
