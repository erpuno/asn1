package isostandard9541fontattributeset

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SETWeightCode int

const (
    SETWeightCodeNotApplicable SETWeightCode = 0
    SETWeightCodeUltraLight SETWeightCode = 1
    SETWeightCodeExtraLight SETWeightCode = 2
    SETWeightCodeLight SETWeightCode = 3
    SETWeightCodeSemiLight SETWeightCode = 4
    SETWeightCodeMedium SETWeightCode = 5
    SETWeightCodeSemiBold SETWeightCode = 6
    SETWeightCodeBold SETWeightCode = 7
    SETWeightCodeExtraBold SETWeightCode = 8
    SETWeightCodeUltraBold SETWeightCode = 9
)

