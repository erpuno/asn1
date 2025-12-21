package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorsOffset struct {
    Leading int64 `asn1:"optional,tag:3"`
    Trailing int64 `asn1:"optional,tag:2"`
    LeftHand int64 `asn1:"optional,tag:1"`
    RightHand int64 `asn1:"optional,tag:0"`
}
