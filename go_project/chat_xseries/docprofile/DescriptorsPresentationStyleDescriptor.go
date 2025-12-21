package docprofile

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/identifiersandexpressions"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorsPresentationStyleDescriptor struct {
    StyleIdentifier identifiersandexpressions.ExpressionsStyleIdentifier
    UserReadableComments DescriptorsCommentString `asn1:"optional,tag:0"`
    UserVisibleName DescriptorsCommentString `asn1:"optional,tag:1"`
    ApplicationComments []byte `asn1:"optional,tag:25"`
    Transparency DescriptorsTransparency `asn1:"optional,tag:2"`
    PresentationAttributes DescriptorsPresentationAttributes `asn1:"optional,tag:3"`
    Colour DescriptorsColour `asn1:"optional,tag:4"`
    ColourOfLayoutObject AttributesColourExpression `asn1:"optional,tag:29"`
    ObjectColourTable AttributesColourTable `asn1:"optional,tag:30"`
    ContentBackgroundColour DescriptorsContentBackgroundColour `asn1:"optional,tag:31"`
    ContentForegroundColour DescriptorsContentForegroundColour `asn1:"optional,tag:32"`
    ContentColourTable AttributesColourTable `asn1:"optional,tag:33"`
    Border DescriptorsBorder `asn1:"optional,tag:5"`
    Sealed DescriptorsSealed `asn1:"optional,tag:6"`
    DerivedFrom identifiersandexpressions.ExpressionsStyleIdentifier `asn1:"optional,tag:7"`
}
