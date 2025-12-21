package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorsMediumType struct {
    NominalPageSize DescriptorsMeasurePair `asn1:"optional"`
    SideOfSheet int64 `asn1:"optional"`
    ColourOfMedium DescriptorsColourOfMedium `asn1:"optional,tag:3"`
}
