package docprofile

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/characterprofileattributes"
    "tobirama/chat_xseries/geogrprofileattributes"
    "tobirama/chat_xseries/rastergrprofileattributes"
    "tobirama/chat_xseries/textunits"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorNonBasicDocCharacteristics struct {
    ProfileCharacterSets []byte `asn1:"optional,tag:5"`
    CommentsCharacterSets []byte `asn1:"optional,tag:1"`
    AlternativeReprCharSets []byte `asn1:"optional,tag:6"`
    PageDimensions []DescriptorsDimensionPair `asn1:"optional,set,tag:2"`
    MediumTypes []DescriptorsMediumType `asn1:"optional,set,tag:8"`
    LayoutPaths []DescriptorsOneOfFourAngles `asn1:"optional,set,tag:21"`
    Transparencies []DescriptorsTransparency `asn1:"optional,set,tag:22"`
    Protections []DescriptorsProtection `asn1:"optional,set,tag:23"`
    BlockAlignments []DescriptorsBlockAlignment `asn1:"optional,set,tag:24"`
    FillOrders []DescriptorsFillOrder `asn1:"optional,set,tag:25"`
    Colours []DescriptorsColour `asn1:"optional,set,tag:26"`
    ColoursOfLayoutObject []AttributesColourExpression `asn1:"optional,set,tag:30"`
    ObjectColourTables []AttributesColourTable `asn1:"optional,set,tag:31"`
    ContentBackgroundColours []DescriptorsContentBackgroundColour `asn1:"optional,set,tag:32"`
    ContentForegroundColours []DescriptorsContentForegroundColour `asn1:"optional,set,tag:33"`
    ContentColourTables []AttributesColourTable `asn1:"optional,set,tag:34"`
    Borders []DescriptorsBorder `asn1:"optional,set,tag:27"`
    PagePositions []DescriptorsMeasurePair `asn1:"optional,set,tag:28"`
    TypesOfCoding []textunits.UnitsTypeOfCoding `asn1:"optional,set,tag:29"`
    CharacterPresentationFeatures []characterprofileattributes.AttributesCharacterPresentationFeature `asn1:"optional,set,tag:9"`
    RaGrPresentationFeatures []rastergrprofileattributes.AttributesRaGrPresentationFeature `asn1:"optional,set,tag:4"`
    GeoGrPresentationFeatures []geogrprofileattributes.AttributesGeoGrPresentationFeature `asn1:"optional,set,tag:12"`
    CharacterCodingAttributes []characterprofileattributes.AttributesCharacterCodingAttribute `asn1:"optional,set,tag:16"`
    RaGrCodingAttributes []rastergrprofileattributes.AttributesRaGrCodingAttribute `asn1:"optional,set,tag:3"`
    GeoGrCodingAttributes []geogrprofileattributes.AttributesGeoGrCodingAttribute `asn1:"optional,set,tag:17"`
    ExtNonBasicPresFeatures []asn1.RawValue `asn1:"optional,tag:10"`
    ExtNonBasicCodingAttributes []asn1.RawValue `asn1:"optional,tag:11"`
}
