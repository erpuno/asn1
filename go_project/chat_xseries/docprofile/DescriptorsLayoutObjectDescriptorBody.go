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

type DescriptorsLayoutObjectDescriptorBody struct {
    ObjectIdentifier identifiersandexpressions.ExpressionsObjectOrClassIdentifier `asn1:"optional"`
    Subordinates []string `asn1:"optional,tag:0"`
    ContentPortions []string `asn1:"optional,tag:1"`
    ObjectClass identifiersandexpressions.ExpressionsObjectOrClassIdentifier `asn1:"optional,tag:2"`
    Position DescriptorsMeasurePair `asn1:"optional,tag:3"`
    Dimensions DescriptorsDimensionPair `asn1:"optional,tag:4"`
    Transparency DescriptorsTransparency `asn1:"optional,tag:5"`
    PresentationAttributes DescriptorsPresentationAttributes `asn1:"optional,tag:6"`
    DefaultValueLists defaultvaluelists.ListsDefaultValueListsLayout `asn1:"optional,tag:7"`
    UserReadableComments DescriptorsCommentString `asn1:"optional,tag:8"`
    Bindings []DescriptorsBindingPair `asn1:"optional,set,tag:9"`
    LayoutPath DescriptorsOneOfFourAngles `asn1:"optional,tag:11"`
    ImagingOrder []string `asn1:"optional,tag:12"`
    LayoutStreamCategories []identifiersandexpressions.ExpressionsCategoryName `asn1:"optional,set,tag:36"`
    LayoutStreamSubCategories []identifiersandexpressions.ExpressionsCategoryName `asn1:"optional,set,tag:37"`
    PermittedCategories []identifiersandexpressions.ExpressionsCategoryName `asn1:"optional,set,tag:13"`
    UserVisibleName DescriptorsCommentString `asn1:"optional,tag:14"`
    PagePosition DescriptorsMeasurePair `asn1:"optional,tag:15"`
    MediumType DescriptorsMediumType `asn1:"optional,tag:16"`
    PresentationStyle identifiersandexpressions.ExpressionsStyleIdentifier `asn1:"optional,tag:17"`
    Balance []identifiersandexpressions.ExpressionsObjectOrClassIdentifier `asn1:"optional,tag:21"`
    Colour DescriptorsColour `asn1:"optional,tag:22"`
    ColourOfLayoutObject AttributesColourExpression `asn1:"optional,tag:29"`
    ObjectColourTable AttributesColourTable `asn1:"optional,tag:30"`
    ContentBackgroundColour DescriptorsContentBackgroundColour `asn1:"optional,tag:31"`
    ContentForegroundColour DescriptorsContentForegroundColour `asn1:"optional,tag:32"`
    ContentColourTable AttributesColourTable `asn1:"optional,tag:33"`
    Border DescriptorsBorder `asn1:"optional,tag:23"`
    ApplicationComments []byte `asn1:"optional,tag:25"`
    Primary identifiersandexpressions.ExpressionsObjectOrClassIdentifier `asn1:"optional,tag:27"`
    Alternative identifiersandexpressions.ExpressionsObjectOrClassIdentifier `asn1:"optional,tag:28"`
    Enciphered DescriptorsEnciphered `asn1:"optional,tag:34"`
    Sealed DescriptorsSealed `asn1:"optional,tag:35"`
    PresentationTime temporalrelationships.RelationshipsPresentationTime `asn1:"optional,tag:52"`
}
