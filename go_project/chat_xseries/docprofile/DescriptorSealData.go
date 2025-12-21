package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorSealData struct {
    SealMethod DescriptorSealMethod `asn1:"optional,tag:0"`
    SealedInformation DescriptorSealedInformation `asn1:"optional,tag:1"`
    Seal []byte `asn1:"tag:2"`
}
