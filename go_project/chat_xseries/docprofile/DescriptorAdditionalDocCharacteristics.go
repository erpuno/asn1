package docprofile

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/temporalrelationships"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorAdditionalDocCharacteristics struct {
    UnitScaling asn1.RawValue `asn1:"optional,tag:3"`
    FontsList DescriptorFontsList `asn1:"optional,set,tag:2"`
    ColourCharacteristics AttributesColourCharacteristics `asn1:"optional,tag:0"`
    ColourSpacesList AttributesColourSpacesList `asn1:"optional,set,tag:1"`
    AssuredReproductionAreas DescriptorAssuredReproductionAreas `asn1:"optional,set,tag:5"`
    TimeScaling temporalrelationships.RelationshipsTimeScaling `asn1:"optional,tag:6"`
    DocumentPresentationTime temporalrelationships.RelationshipsDocumentPresentationTime `asn1:"optional,tag:7"`
}
