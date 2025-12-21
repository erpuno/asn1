package docprofile

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/identifiersandexpressions"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorsEnciphered struct {
    EncipheredSubordinates asn1.RawValue
    ProtectedPartId identifiersandexpressions.ExpressionsProtectedPartIdentifier `asn1:"optional,tag:2"`
}
