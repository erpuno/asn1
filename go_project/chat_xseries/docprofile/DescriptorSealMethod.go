package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorSealMethod struct {
    FingerprintMethod DescriptorMethodInformation `asn1:"optional,tag:0"`
    FingerprintKeyInformation DescriptorKeyInformation `asn1:"optional,tag:1"`
    SealingMethod DescriptorMethodInformation `asn1:"optional,tag:2"`
    SealingKeyInformation DescriptorKeyInformation `asn1:"optional,tag:3"`
}
