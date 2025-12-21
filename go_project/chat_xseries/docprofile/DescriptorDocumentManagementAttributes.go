package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorDocumentManagementAttributes struct {
    DocumentDescription DescriptorDocumentDescription `asn1:"optional,tag:7"`
    DatesAndTimes DescriptorDatesAndTimes `asn1:"optional,tag:0"`
    Originators DescriptorOriginators `asn1:"optional,tag:1"`
    OtherUserInformation DescriptorOtherUserInformation `asn1:"optional,tag:2"`
    ExternalReferences DescriptorExternalReferences `asn1:"optional,tag:3"`
    LocalFileReferences DescriptorLocalFileReferences `asn1:"optional,set,tag:4"`
    ContentAttributes DescriptorContentAttributes `asn1:"optional,tag:5"`
    SecurityInformation DescriptorSecurityInformation `asn1:"optional,tag:6"`
}
