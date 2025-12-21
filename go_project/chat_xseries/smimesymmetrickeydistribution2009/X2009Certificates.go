package smimesymmetrickeydistribution2009

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/cryptographicmessagesyntax2009"
    "tobirama/chat_xseries/pkixattributecertificate2009"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009Certificates struct {
    PKC asn1.RawValue `asn1:"optional,tag:0"`
    AC []pkixattributecertificate2009.X2009AttributeCertificate `asn1:"optional,tag:1"`
    CertPath cryptographicmessagesyntax2009.X2009CertificateSet `asn1:"optional,set,tag:2"`
}
