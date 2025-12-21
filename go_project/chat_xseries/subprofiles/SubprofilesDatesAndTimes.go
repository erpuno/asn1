package subprofiles

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/docprofile"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SubprofilesDatesAndTimes struct {
    DocumentFragmentDateAndTime docprofile.DescriptorDateAndTime `asn1:"optional,tag:0"`
    CreationDateAndTime docprofile.DescriptorDateAndTime `asn1:"optional,tag:1"`
    LocalFilingDateAndTime []docprofile.DescriptorDateAndTime `asn1:"optional,tag:2"`
    ExpiryDateAndTime docprofile.DescriptorDateAndTime `asn1:"optional,tag:3"`
    StartDateAndTime docprofile.DescriptorDateAndTime `asn1:"optional,tag:4"`
    PurgeDateAndTime docprofile.DescriptorDateAndTime `asn1:"optional,tag:5"`
    ReleaseDateAndTime docprofile.DescriptorDateAndTime `asn1:"optional,tag:6"`
    RevisionHistory []asn1.RawValue `asn1:"optional,tag:7"`
}
