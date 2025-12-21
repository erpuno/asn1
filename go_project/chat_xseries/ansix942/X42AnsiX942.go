package ansix942

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

var X42AnsiX942 = asn1.ObjectIdentifier{1, 2, 840, 10046}
