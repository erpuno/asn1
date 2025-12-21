package pkcs8

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X8Version int

const (
    X8VersionV1 X8Version = 0
)

