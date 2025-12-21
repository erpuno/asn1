package pkix1implicit2009

import (
    "encoding/asn1"
    "time"
    "tobirama/chat/pkix1explicit2009"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009AuthorityKeyIdentifier struct {
    KeyIdentifier X2009KeyIdentifier `asn1:"optional,tag:0"`
    AuthorityCertIssuer asn1.RawValue `asn1:"optional,tag:1"`
    AuthorityCertSerialNumber pkix1explicit2009.X2009CertificateSerialNumber `asn1:"optional,tag:2"`
}
