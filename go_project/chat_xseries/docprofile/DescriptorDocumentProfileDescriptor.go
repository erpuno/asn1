package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorDocumentProfileDescriptor struct {
    GenericLayoutStructure string `asn1:"optional,tag:0"`
    SpecificLayoutStructure string `asn1:"optional,tag:1"`
    GenericLogicalStructure string `asn1:"optional,tag:4"`
    SpecificLogicalStructure string `asn1:"optional,tag:5"`
    PresentationStyles string `asn1:"optional,tag:6"`
    LayoutStyles string `asn1:"optional,tag:7"`
    SealedProfiles string `asn1:"optional,tag:12"`
    EncipheredProfiles string `asn1:"optional,tag:13"`
    PreencipheredBodyparts string `asn1:"optional,tag:14"`
    PostencipheredBodyparts string `asn1:"optional,tag:15"`
    ExternalDocumentClass DescriptorDocumentReference `asn1:"optional,tag:9"`
    ResourceDocument DescriptorDocumentReference `asn1:"optional,tag:10"`
    Resources []asn1.RawValue `asn1:"optional,set,tag:11"`
    DocumentCharacteristics DescriptorDocumentCharacteristics `asn1:"tag:2"`
    DocumentManagementAttributes DescriptorDocumentManagementAttributes `asn1:"optional,tag:3"`
    DocumentSecurityAttributes DescriptorDocumentSecurityAttributes `asn1:"optional,tag:16"`
    Links string `asn1:"optional,tag:17"`
    LinkClasses string `asn1:"optional,tag:18"`
    EncipheredLinks string `asn1:"optional,tag:19"`
    TemporalRelations string `asn1:"optional,tag:20"`
}
