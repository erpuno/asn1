package pkixalgs2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

var X2009Secp256r1 = asn1.ObjectIdentifier{1, 2, 840, 10045, 3, 1, 7}
