package isostandard9541fontattributeset

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SETPostureCode int

const (
    SETPostureCodeNotApplicable SETPostureCode = 0
    SETPostureCodeUpright SETPostureCode = 1
    SETPostureCodeObliqueForward SETPostureCode = 2
    SETPostureCodeObliqueBackward SETPostureCode = 3
    SETPostureCodeItalicForward SETPostureCode = 4
    SETPostureCodeItalicBackward SETPostureCode = 5
    SETPostureCodeOther SETPostureCode = 6
)

