package extendedsecurityservices2009

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/pkix1implicit2009"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009SigningCertificate struct {
    Certs []X2009ESSCertID
    Policies []pkix1implicit2009.X2009PolicyInformation `asn1:"optional"`
}
