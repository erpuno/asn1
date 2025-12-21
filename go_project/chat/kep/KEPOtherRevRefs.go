package kep

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type KEPOtherRevRefs struct {
    OtherRevRefType KEPOtherRevRefType
    OtherRevRefs asn1.RawValue
}
