package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorsSealed struct {
    SealedStatus int64 `asn1:"tag:0"`
    SealIds []int64 `asn1:"optional,set,tag:1"`
}
