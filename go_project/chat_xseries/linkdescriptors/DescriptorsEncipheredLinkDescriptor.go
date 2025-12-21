package linkdescriptors

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/identifiersandexpressions"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorsEncipheredLinkDescriptor struct {
    ProtectedPartIdentifier identifiersandexpressions.ExpressionsProtectedPartIdentifier
    EncipheredInformation []byte
}
