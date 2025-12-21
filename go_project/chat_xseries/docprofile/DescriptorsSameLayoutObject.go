package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorsSameLayoutObject struct {
    LogicalObject asn1.RawValue
    LayoutObject asn1.RawValue `asn1:"optional"`
}
