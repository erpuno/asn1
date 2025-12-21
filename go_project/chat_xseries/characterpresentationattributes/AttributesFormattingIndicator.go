package characterpresentationattributes

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesFormattingIndicator int

const (
    AttributesFormattingIndicatorNo AttributesFormattingIndicator = 0
    AttributesFormattingIndicatorYes AttributesFormattingIndicator = 1
)

