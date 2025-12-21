package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorsColour int

const (
    DescriptorsColourColourOfMedia DescriptorsColour = 0
    DescriptorsColourColoured DescriptorsColour = 1
)

