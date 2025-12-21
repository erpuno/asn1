package isostandard9541fontattributeset

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SETWidthCode int

const (
    SETWidthCodeNotApplicable SETWidthCode = 0
    SETWidthCodeUltraCondensed SETWidthCode = 1
    SETWidthCodeExtraCondensed SETWidthCode = 2
    SETWidthCodeCondensed SETWidthCode = 3
    SETWidthCodeSemiCondensed SETWidthCode = 4
    SETWidthCodeMedium SETWidthCode = 5
    SETWidthCodeSemiExpanded SETWidthCode = 6
    SETWidthCodeExpanded SETWidthCode = 7
    SETWidthCodeExtraExpanded SETWidthCode = 8
    SETWidthCodeUltraExpanded SETWidthCode = 9
)

