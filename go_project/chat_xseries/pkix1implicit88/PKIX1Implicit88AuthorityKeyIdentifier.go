package pkix1implicit88

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/pkix1explicit88"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type PKIX1Implicit88AuthorityKeyIdentifier struct {
    KeyIdentifier PKIX1Implicit88KeyIdentifier `asn1:"optional,tag:0"`
    AuthorityCertIssuer asn1.RawValue `asn1:"optional,tag:1"`
    AuthorityCertSerialNumber pkix1explicit88.PKIX1Explicit88CertificateSerialNumber `asn1:"optional,tag:2"`
}
