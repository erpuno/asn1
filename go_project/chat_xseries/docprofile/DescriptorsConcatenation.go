package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorsConcatenation int

const (
    DescriptorsConcatenationNonConcatenated DescriptorsConcatenation = 0
    DescriptorsConcatenationConcatenated DescriptorsConcatenation = 1
)

