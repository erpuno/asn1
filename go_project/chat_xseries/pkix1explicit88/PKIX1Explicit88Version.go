package pkix1explicit88

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type PKIX1Explicit88Version int

const (
    PKIX1Explicit88VersionV1 PKIX1Explicit88Version = 0
    PKIX1Explicit88VersionV2 PKIX1Explicit88Version = 1
    PKIX1Explicit88VersionV3 PKIX1Explicit88Version = 2
)

