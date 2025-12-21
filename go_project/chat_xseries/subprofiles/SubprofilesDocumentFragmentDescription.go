package subprofiles

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/docprofile"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SubprofilesDocumentFragmentDescription struct {
    Title docprofile.DescriptorCharacterData `asn1:"optional,tag:0"`
    Subject docprofile.DescriptorCharacterData `asn1:"optional,tag:1"`
    DocumentFragmentType docprofile.DescriptorCharacterData `asn1:"optional,tag:2"`
    Abstract docprofile.DescriptorCharacterData `asn1:"optional,tag:3"`
    Keywords []docprofile.DescriptorCharacterData `asn1:"optional,set,tag:4"`
}
