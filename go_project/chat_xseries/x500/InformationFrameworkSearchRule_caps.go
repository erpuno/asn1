package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type InformationFrameworkSearchRule struct {
    ServiceType asn1.ObjectIdentifier `asn1:"optional,tag:1"`
    UserClass int64 `asn1:"optional,tag:2"`
    InputAttributeTypes []InformationFrameworkRequestAttribute `asn1:"optional,tag:3"`
    AttributeCombination InformationFrameworkAttributeCombination `asn1:"tag:4"`
    OutputAttributeTypes []InformationFrameworkResultAttribute `asn1:"optional,tag:5"`
    DefaultControls InformationFrameworkControlOptions `asn1:"optional,tag:6"`
    MandatoryControls InformationFrameworkControlOptions `asn1:"optional,tag:7"`
    SearchRuleControls InformationFrameworkControlOptions `asn1:"optional,tag:8"`
    FamilyGrouping DirectoryAbstractServiceFamilyGrouping `asn1:"optional,tag:9"`
    FamilyReturn DirectoryAbstractServiceFamilyReturn `asn1:"optional,tag:10"`
    Relaxation InformationFrameworkRelaxationPolicy `asn1:"optional,tag:11"`
    AdditionalControl []asn1.ObjectIdentifier `asn1:"optional,tag:12"`
    AllowedSubset InformationFrameworkAllowedSubset `asn1:"tag:13"`
    ImposedSubset InformationFrameworkImposedSubset `asn1:"optional,tag:14"`
    EntryLimit InformationFrameworkEntryLimit `asn1:"optional,tag:15"`
}
