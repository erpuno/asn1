package pkix1explicit2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

var X2009IdPkix = asn1.ObjectIdentifier{1, 3, 6, 1, 5, 5, 7}
