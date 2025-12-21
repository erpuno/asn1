package subprofiles

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/docprofile"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SubprofilesDocumentFragmentManagementAttributes struct {
    DocumentFragmentDescription SubprofilesDocumentFragmentDescription `asn1:"optional,tag:0"`
    DatesAndTimes SubprofilesDatesAndTimes `asn1:"optional,tag:1"`
    Originators docprofile.DescriptorOriginators `asn1:"optional,tag:2"`
    OtherUserInformation docprofile.DescriptorOtherUserInformation `asn1:"optional,tag:3"`
    ExternalReferences SubprofilesExternalReferences2 `asn1:"optional,tag:4"`
    LocalFileReferences docprofile.DescriptorLocalFileReferences `asn1:"optional,set,tag:5"`
    Languages []docprofile.DescriptorCharacterData `asn1:"optional,set,tag:6"`
    SecurityInformation docprofile.DescriptorSecurityInformation `asn1:"optional,tag:7"`
}
