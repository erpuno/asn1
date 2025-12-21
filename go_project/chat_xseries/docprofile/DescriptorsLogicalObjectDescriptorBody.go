package docprofile

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/defaultvaluelists"
    "tobirama/chat_xseries/identifiersandexpressions"
    "tobirama/chat_xseries/temporalrelationships"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorsLogicalObjectDescriptorBody struct {
    ObjectIdentifier identifiersandexpressions.ExpressionsObjectOrClassIdentifier `asn1:"optional"`
    Subordinates []string `asn1:"optional,tag:0"`
    ContentPortions []string `asn1:"optional,tag:1"`
    ObjectClass identifiersandexpressions.ExpressionsObjectOrClassIdentifier `asn1:"optional,tag:2"`
    PresentationAttributes DescriptorsPresentationAttributes `asn1:"optional,tag:6"`
    DefaultValueLists defaultvaluelists.ListsDefaultValueListsLogical `asn1:"optional,tag:7"`
    UserReadableComments DescriptorsCommentString `asn1:"optional,tag:8"`
    Bindings []DescriptorsBindingPair `asn1:"optional,set,tag:9"`
    ContentGenerator identifiersandexpressions.ExpressionsStringExpression `asn1:"optional,tag:10"`
    UserVisibleName DescriptorsCommentString `asn1:"optional,tag:14"`
    PresentationStyle identifiersandexpressions.ExpressionsStyleIdentifier `asn1:"optional,tag:17"`
    LayoutStyle identifiersandexpressions.ExpressionsStyleIdentifier `asn1:"optional,tag:19"`
    Protection DescriptorsProtection `asn1:"optional,tag:20"`
    ApplicationComments []byte `asn1:"optional,tag:25"`
    Primary identifiersandexpressions.ExpressionsObjectOrClassIdentifier `asn1:"optional,tag:27"`
    Alternative identifiersandexpressions.ExpressionsObjectOrClassIdentifier `asn1:"optional,tag:28"`
    Enciphered DescriptorsEnciphered `asn1:"optional,tag:34"`
    Sealed DescriptorsSealed `asn1:"optional,tag:35"`
    TemporalRelations temporalrelationships.RelationshipsTemporalRelations `asn1:"optional,tag:36"`
}
