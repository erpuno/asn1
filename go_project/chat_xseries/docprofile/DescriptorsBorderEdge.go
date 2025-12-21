package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorsBorderEdge struct {
    LineWidth int64 `asn1:"optional,tag:0"`
    LineType int64 `asn1:"optional,tag:1"`
    FreespaceWidth int64 `asn1:"optional,tag:2"`
    BorderLineColour DescriptorsBorderLineColour `asn1:"optional,tag:3"`
}
