package characterpresentationattributes

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesCharacterAttributes struct {
    CharacterPath AttributesOneOfFourAngles `asn1:"optional,tag:0"`
    LineProgression AttributesOneOfTwoAngles `asn1:"optional,tag:1"`
    CharacterOrientation AttributesOneOfFourAngles `asn1:"optional,tag:2"`
    InitialOffset AttributesMeasurePair `asn1:"optional,tag:3"`
    CharacterSpacing int64 `asn1:"optional,tag:6"`
    LineSpacing int64 `asn1:"optional,tag:7"`
    Alignment AttributesAlignment `asn1:"optional,tag:8"`
    LineLayoutTable AttributesLayoutTable `asn1:"optional,set,tag:9"`
    GraphicRendition AttributesGraphicRendition `asn1:"optional,set,tag:10"`
    FormattingIndicator AttributesFormattingIndicator `asn1:"optional,tag:11"`
    CharacterFonts AttributesCharacterFonts `asn1:"optional,tag:12"`
    GraphicCharSubrepertoire int64 `asn1:"optional,tag:13"`
    Itemization AttributesItemization `asn1:"optional,tag:14"`
    WidowSize int64 `asn1:"optional,tag:15"`
    OrphanSize int64 `asn1:"optional,tag:16"`
    GraphicCharacterSets []byte `asn1:"optional,tag:17"`
    Indentation int64 `asn1:"optional,tag:19"`
    KerningOffset AttributesKerningOffset `asn1:"optional,tag:20"`
    ProportionalLineSpacing AttributesProportionalLineSpacing `asn1:"optional,tag:21"`
    PairwiseKerning AttributesPairwiseKerning `asn1:"optional,tag:22"`
    FirstLineOffset int64 `asn1:"optional,tag:23"`
    CodeExtensionAnnouncers []byte `asn1:"optional,tag:24"`
}
