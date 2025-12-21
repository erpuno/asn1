package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesColourModesPresent int

const (
    AttributesColourModesPresentDirect AttributesColourModesPresent = 0
    AttributesColourModesPresentIndexed AttributesColourModesPresent = 1
    AttributesColourModesPresentBoth AttributesColourModesPresent = 2
)

