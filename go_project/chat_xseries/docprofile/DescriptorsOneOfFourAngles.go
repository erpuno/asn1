package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorsOneOfFourAngles int

const (
    DescriptorsOneOfFourAnglesD0 DescriptorsOneOfFourAngles = 0
    DescriptorsOneOfFourAnglesD90 DescriptorsOneOfFourAngles = 1
    DescriptorsOneOfFourAnglesD180 DescriptorsOneOfFourAngles = 2
    DescriptorsOneOfFourAnglesD270 DescriptorsOneOfFourAngles = 3
)

