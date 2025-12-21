package defaultvaluelists

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type ListsCompositeLogicalAttributes struct {
    Protection asn1.RawValue `asn1:"optional"`
    LayoutStyle asn1.RawValue `asn1:"optional"`
    Sealed asn1.RawValue `asn1:"optional"`
}
