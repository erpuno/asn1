package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorAssuredReproductionAreasElement struct {
    NominalPageSize DescriptorsMeasurePair `asn1:"tag:0"`
    AssuredReproductionArea asn1.RawValue `asn1:"set,tag:1"`
}
