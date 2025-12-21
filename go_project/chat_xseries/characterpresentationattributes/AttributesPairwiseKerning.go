package characterpresentationattributes

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesPairwiseKerning int

const (
    AttributesPairwiseKerningNo AttributesPairwiseKerning = 0
    AttributesPairwiseKerningYes AttributesPairwiseKerning = 1
)

