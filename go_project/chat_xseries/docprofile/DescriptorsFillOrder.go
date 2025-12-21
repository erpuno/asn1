package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorsFillOrder int

const (
    DescriptorsFillOrderNormal DescriptorsFillOrder = 0
    DescriptorsFillOrderReverse DescriptorsFillOrder = 1
)

