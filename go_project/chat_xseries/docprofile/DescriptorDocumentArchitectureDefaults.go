package docprofile

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/textunits"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorDocumentArchitectureDefaults struct {
    ContentArchitectureClass asn1.RawValue `asn1:"optional"`
    PageDimensions DescriptorsMeasurePair `asn1:"optional,tag:2"`
    Transparency DescriptorsTransparency `asn1:"optional,tag:3"`
    Colour DescriptorsColour `asn1:"optional,tag:4"`
    ColourOfLayoutObject AttributesColourExpression `asn1:"optional,tag:11"`
    ObjectColourTable AttributesColourTable `asn1:"optional,tag:12"`
    ContentBackgroundColour DescriptorsContentBackgroundColour `asn1:"optional,tag:13"`
    ContentForegroundColour DescriptorsContentForegroundColour `asn1:"optional,tag:14"`
    ContentColourTable AttributesColourTable `asn1:"optional,tag:15"`
    LayoutPath DescriptorsOneOfFourAngles `asn1:"optional,tag:5"`
    MediumType DescriptorsMediumType `asn1:"optional,tag:6"`
    BlockAlignment DescriptorsBlockAlignment `asn1:"optional,tag:7"`
    Border DescriptorsBorder `asn1:"optional,tag:8"`
    PagePosition DescriptorsMeasurePair `asn1:"optional,tag:9"`
    TypeOfCoding textunits.UnitsTypeOfCoding `asn1:"optional,tag:10"`
}
