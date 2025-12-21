package isostandard9541fontattributeset

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SETStructureCode int

const (
    SETStructureCodeNotApplicable SETStructureCode = 0
    SETStructureCodeSolid SETStructureCode = 1
    SETStructureCodeOutline SETStructureCode = 2
)

