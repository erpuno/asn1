package linkdescriptors

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/docprofile"
    "tobirama/chat_xseries/identifiersandexpressions"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorsLinkEnd struct {
    Reference asn1.RawValue `asn1:"set"`
    UserReadableComments docprofile.DescriptorsCommentString `asn1:"optional,tag:2"`
    UserVisibleName docprofile.DescriptorsCommentString `asn1:"optional,tag:3"`
    PresentationStyle identifiersandexpressions.ExpressionsStyleIdentifier `asn1:"optional,tag:17"`
    LayoutStyle identifiersandexpressions.ExpressionsStyleIdentifier `asn1:"optional,tag:19"`
    ApplicationComments []byte `asn1:"optional,tag:25"`
}
