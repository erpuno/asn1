package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorSealedInformation struct {
    Fingerprint []byte `asn1:"optional,tag:0"`
    Time DescriptorDateAndTime `asn1:"optional,tag:1"`
    SealingOrigId DescriptorPersonalName `asn1:"optional,tag:2"`
    Location DescriptorLocation `asn1:"optional,tag:3"`
}
