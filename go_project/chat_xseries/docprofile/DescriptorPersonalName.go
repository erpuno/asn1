package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorPersonalName struct {
    Surname DescriptorCharacterData `asn1:"tag:0"`
    Givenname DescriptorCharacterData `asn1:"optional,tag:1"`
    Initials DescriptorCharacterData `asn1:"optional,tag:2"`
    GenerationQualifier DescriptorCharacterData `asn1:"optional,tag:3"`
}
