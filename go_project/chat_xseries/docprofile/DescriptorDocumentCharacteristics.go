package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorDocumentCharacteristics struct {
    DocumentApplicationProfile asn1.RawValue `asn1:"optional"`
    DocApplProfileDefaults DescriptorDocApplProfileDefaults `asn1:"optional,tag:10"`
    DocumentArchitectureClass int64 `asn1:"tag:1"`
    ContentArchitectureClasses []asn1.ObjectIdentifier `asn1:"set,tag:5"`
    InterchangeFormatClass int64 `asn1:"tag:6"`
    OdaVersion DescriptorODAVersion `asn1:"tag:8"`
    AlternativeFeatureSets [][]asn1.ObjectIdentifier `asn1:"optional,set,tag:11"`
    NonBasicDocCharacteristics DescriptorNonBasicDocCharacteristics `asn1:"optional,tag:2"`
    NonBasicStrucCharacteristics DescriptorNonBasicStrucCharacteristics `asn1:"optional,tag:3"`
    AdditionalDocCharacteristics DescriptorAdditionalDocCharacteristics `asn1:"optional,tag:9"`
}
