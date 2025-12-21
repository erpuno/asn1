package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorsFloatabilityRange struct {
    ForwardLimit asn1.RawValue `asn1:"optional,tag:0"`
    BackwardLimit asn1.RawValue `asn1:"optional,tag:1"`
}
