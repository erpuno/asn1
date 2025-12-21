package docprofile

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/identifiersandexpressions"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorProtectedDocPartsElement struct {
    ProtectedDocPartId identifiersandexpressions.ExpressionsProtectedPartIdentifier `asn1:"tag:0"`
    PrivRecipientsInfo []DescriptorPrivRecipientsInfo `asn1:"set,tag:1"`
}
