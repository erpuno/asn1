package textunits

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type UnitsTextUnit struct {
    ContentPortionAttributes UnitsContentPortionAttributes `asn1:"optional"`
    ContentInformation UnitsContentInformation `asn1:"optional"`
}
