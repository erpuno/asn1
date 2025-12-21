package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorsPositionSpec struct {
    Offset asn1.RawValue `asn1:"optional,set,tag:0"`
    Separation asn1.RawValue `asn1:"optional,set,tag:1"`
    Alignment int64 `asn1:"optional,tag:2"`
    FillOrder int64 `asn1:"optional,tag:3"`
}
