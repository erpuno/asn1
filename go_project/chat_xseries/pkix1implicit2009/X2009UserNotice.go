package pkix1implicit2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009UserNotice struct {
    NoticeRef X2009NoticeReference `asn1:"optional"`
    ExplicitText X2009DisplayText `asn1:"optional"`
}
