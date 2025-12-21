package characterpresentationattributes

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesProportionalLineSpacing int

const (
    AttributesProportionalLineSpacingNo AttributesProportionalLineSpacing = 0
    AttributesProportionalLineSpacingYes AttributesProportionalLineSpacing = 1
)

