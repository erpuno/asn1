package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorsMeasurePair struct {
    Horizontal asn1.RawValue
    Vertical asn1.RawValue
}
