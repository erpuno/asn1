package isostandard9541fontattributeset

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SETECode int

const (
    SETECodeNotApplicable SETECode = 0
    SETECodeLetterSpace SETECode = 1
    SETECodeWordSpace SETECode = 2
    SETECodeNoAdjust SETECode = 3
)

