package ansix942

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X42ValidationParms struct {
    Seed asn1.BitString
    PGenCounter int64
}
