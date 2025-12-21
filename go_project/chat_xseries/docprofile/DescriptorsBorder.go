package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorsBorder struct {
    LeftHandEdge DescriptorsBorderEdge `asn1:"optional,tag:0"`
    RightHandEdge DescriptorsBorderEdge `asn1:"optional,tag:1"`
    TrailingEdge DescriptorsBorderEdge `asn1:"optional,tag:2"`
    LeadingEdge DescriptorsBorderEdge `asn1:"optional,tag:3"`
}
