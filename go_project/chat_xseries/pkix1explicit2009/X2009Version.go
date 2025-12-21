package pkix1explicit2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009Version int

const (
    X2009VersionV1 X2009Version = 0
    X2009VersionV2 X2009Version = 1
    X2009VersionV3 X2009Version = 2
)

