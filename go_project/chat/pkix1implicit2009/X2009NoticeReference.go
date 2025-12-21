package pkix1implicit2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009NoticeReference struct {
    Organization X2009DisplayText
    NoticeNumbers []int64
}
