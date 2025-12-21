package linkdescriptors

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/docprofile"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorsLinkRole struct {
    LinkEnds []DescriptorsLinkEnd `asn1:"set"`
    UserReadableComments docprofile.DescriptorsCommentString `asn1:"optional,tag:2"`
    UserVisibleName docprofile.DescriptorsCommentString `asn1:"optional,tag:3"`
    ApplicationComments []byte `asn1:"optional,tag:25"`
}
