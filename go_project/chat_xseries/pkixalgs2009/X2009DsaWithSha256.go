package pkixalgs2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

var X2009DsaWithSha256 = asn1.ObjectIdentifier{2, 16, 840, 1, 101, 3, 4, 3, 2}
