package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorSealedDocBodypartsElement struct {
    SealId int64 `asn1:"tag:0"`
    SealedConstituents DescriptorSealedConstituents `asn1:"tag:1"`
    PrivilegedRecipients []DescriptorPersonalName `asn1:"optional,set,tag:2"`
    DocBodypartSeal DescriptorSealData `asn1:"tag:3"`
}
