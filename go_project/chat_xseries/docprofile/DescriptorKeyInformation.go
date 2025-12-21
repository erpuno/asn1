package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorKeyInformation struct {
    MethodInformation DescriptorMethodInformation `asn1:"optional,tag:0"`
    AdditionalInformation DescriptorAdditionalInformation `asn1:"optional,tag:1"`
}
