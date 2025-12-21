package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorAdditionalInformation struct {
    DescriptiveInformation DescriptorCharacterData `asn1:"optional,tag:0"`
    OctetString []byte `asn1:"optional,tag:1"`
}
