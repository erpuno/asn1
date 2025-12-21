package cryptographicmessagesyntax2010

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2010RecipientKeyIdentifier struct {
    SubjectKeyIdentifier X2010SubjectKeyIdentifier
    Date time.Time `asn1:"optional"`
    Other X2010OtherKeyAttribute `asn1:"optional"`
}
