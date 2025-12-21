package cryptographicmessagesyntax2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009OriginatorInfo struct {
    Certs X2009CertificateSet `asn1:"optional,set,tag:0"`
    Crls X2009RevocationInfoChoices `asn1:"optional,set,tag:1"`
}
