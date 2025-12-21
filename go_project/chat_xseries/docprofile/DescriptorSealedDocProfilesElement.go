package docprofile

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/identifiersandexpressions"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorSealedDocProfilesElement struct {
    SealedDocProfDescriptorId identifiersandexpressions.ExpressionsProtectedPartIdentifier `asn1:"tag:0"`
    PrivilegedRecipients []DescriptorPersonalName `asn1:"optional,set,tag:1"`
    DocProfSeal DescriptorSealData `asn1:"tag:2"`
}
