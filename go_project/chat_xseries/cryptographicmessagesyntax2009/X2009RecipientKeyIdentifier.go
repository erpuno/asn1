package cryptographicmessagesyntax2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009RecipientKeyIdentifier struct {
    SubjectKeyIdentifier X2009SubjectKeyIdentifier
    Date time.Time `asn1:"optional"`
    Other X2009OtherKeyAttribute `asn1:"optional"`
}
