package isostandard9541fontattributeset

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SETEscClassCode int

const (
    SETEscClassCodeNotApplicable SETEscClassCode = 0
    SETEscClassCodeMonospace SETEscClassCode = 1
    SETEscClassCodeProportional SETEscClassCode = 2
)

