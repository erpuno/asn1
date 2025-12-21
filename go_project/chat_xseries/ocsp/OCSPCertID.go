package ocsp

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/pkix1explicit88"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type OCSPCertID struct {
    HashAlgorithm asn1.RawValue
    IssuerNameHash []byte
    IssuerKeyHash []byte
    SerialNumber pkix1explicit88.PKIX1Explicit88CertificateSerialNumber
}
