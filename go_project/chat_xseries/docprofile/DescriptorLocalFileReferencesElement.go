package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorLocalFileReferencesElement struct {
    FileName DescriptorCharacterData `asn1:"optional,tag:0"`
    Location DescriptorCharacterData `asn1:"optional,tag:1"`
    UserComments DescriptorCharacterData `asn1:"optional,tag:2"`
}
