package cryptographicmessagesyntax2010

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/pkix1explicit2009"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2010IssuerAndSerialNumber struct {
    Issuer pkix1explicit2009.X2009Name
    SerialNumber pkix1explicit2009.X2009CertificateSerialNumber
}
