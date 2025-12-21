package pkix1implicit88

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type PKIX1Implicit88UserNotice struct {
    NoticeRef PKIX1Implicit88NoticeReference `asn1:"optional"`
    ExplicitText PKIX1Implicit88DisplayText `asn1:"optional"`
}
