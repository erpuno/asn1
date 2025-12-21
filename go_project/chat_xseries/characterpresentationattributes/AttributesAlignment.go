package characterpresentationattributes

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesAlignment int

const (
    AttributesAlignmentStartAligned AttributesAlignment = 0
    AttributesAlignmentEndAligned AttributesAlignment = 1
    AttributesAlignmentCentred AttributesAlignment = 2
    AttributesAlignmentJustified AttributesAlignment = 3
)

