package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorSecurityInformation struct {
    Authorization asn1.RawValue `asn1:"optional"`
    SecurityClassification DescriptorCharacterData `asn1:"optional,tag:1"`
    AccessRights []DescriptorCharacterData `asn1:"optional,set,tag:2"`
}
