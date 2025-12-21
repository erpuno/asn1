package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorsBlockAlignment int

const (
    DescriptorsBlockAlignmentRightHand DescriptorsBlockAlignment = 0
    DescriptorsBlockAlignmentLeftHand DescriptorsBlockAlignment = 1
    DescriptorsBlockAlignmentCentred DescriptorsBlockAlignment = 2
    DescriptorsBlockAlignmentNull DescriptorsBlockAlignment = 3
)

