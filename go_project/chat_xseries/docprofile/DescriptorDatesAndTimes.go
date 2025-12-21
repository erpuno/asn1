package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorDatesAndTimes struct {
    DocumentDateAndTime DescriptorDateAndTime `asn1:"optional,tag:0"`
    CreationDateAndTime DescriptorDateAndTime `asn1:"optional,tag:1"`
    LocalFilingDateAndTime []DescriptorDateAndTime `asn1:"optional,tag:2"`
    ExpiryDateAndTime DescriptorDateAndTime `asn1:"optional,tag:3"`
    StartDateAndTime DescriptorDateAndTime `asn1:"optional,tag:4"`
    PurgeDateAndTime DescriptorDateAndTime `asn1:"optional,tag:5"`
    ReleaseDateAndTime DescriptorDateAndTime `asn1:"optional,tag:6"`
    RevisionHistory []asn1.RawValue `asn1:"optional,tag:7"`
}
