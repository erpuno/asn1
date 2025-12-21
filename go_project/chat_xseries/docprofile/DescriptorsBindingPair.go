package docprofile

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/identifiersandexpressions"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorsBindingPair struct {
    BindingIdentifier identifiersandexpressions.ExpressionsBindingName `asn1:"tag:0"`
    BindingValue asn1.RawValue
}
