package linkdescriptors

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/docprofile"
    "tobirama/chat_xseries/temporalrelationships"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorsLinkDescriptor struct {
    LinkIdentifier DescriptorsLinkOrLinkClassIdentifier
    LinkClass DescriptorsLinkOrLinkClassIdentifier `asn1:"optional,tag:0"`
    LinkRoles []DescriptorsLinkRole `asn1:"optional,tag:1"`
    UserReadableComments docprofile.DescriptorsCommentString `asn1:"optional,tag:2"`
    UserVisibleName docprofile.DescriptorsCommentString `asn1:"optional,tag:3"`
    ApplicationComments []byte `asn1:"optional,tag:25"`
    Sealed docprofile.DescriptorsSealed `asn1:"optional,tag:35"`
    TemporalRelations temporalrelationships.RelationshipsTemporalRelations `asn1:"optional,tag:38"`
    PresentationTime temporalrelationships.RelationshipsPresentationTime `asn1:"optional,tag:39"`
}
