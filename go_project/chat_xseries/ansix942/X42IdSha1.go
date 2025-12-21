package ansix942

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

var X42IdSha1 = asn1.ObjectIdentifier{1, 3, 14, 3, 2, 26}
