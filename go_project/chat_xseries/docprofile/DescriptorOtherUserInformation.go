package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorOtherUserInformation struct {
    Copyright []asn1.RawValue `asn1:"optional,set,tag:0"`
    Status DescriptorCharacterData `asn1:"optional,tag:1"`
    UserSpecificCodes []DescriptorCharacterData `asn1:"optional,set,tag:2"`
    DistributionList []asn1.RawValue `asn1:"optional,tag:3"`
    AdditionalInformation asn1.RawValue `asn1:"optional,tag:5"`
}
