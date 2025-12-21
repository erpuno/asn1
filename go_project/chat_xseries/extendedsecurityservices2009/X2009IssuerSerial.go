package extendedsecurityservices2009

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/pkix1explicit2009"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009IssuerSerial struct {
    Issuer asn1.RawValue
    SerialNumber pkix1explicit2009.X2009CertificateSerialNumber
}
