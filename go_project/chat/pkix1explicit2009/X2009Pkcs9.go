package pkix1explicit2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

var X2009Pkcs9 = asn1.ObjectIdentifier{1, 2, 840, 113549, 1, 9}
