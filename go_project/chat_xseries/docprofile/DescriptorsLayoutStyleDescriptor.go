package docprofile

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/identifiersandexpressions"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorsLayoutStyleDescriptor struct {
    StyleIdentifier identifiersandexpressions.ExpressionsStyleIdentifier
    UserReadableComments DescriptorsCommentString `asn1:"optional,tag:0"`
    UserVisibleName DescriptorsCommentString `asn1:"optional,tag:1"`
    ApplicationComments []byte `asn1:"optional,tag:25"`
    LayoutDirectives DescriptorsLayoutDirectives `asn1:"optional,tag:4"`
    Sealed DescriptorsSealed `asn1:"optional,tag:6"`
    DerivedFrom identifiersandexpressions.ExpressionsStyleIdentifier `asn1:"optional,tag:7"`
}
