package pkcs9

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

var X9Pkcs9 = asn1.ObjectIdentifier{1, 2, 840, 113549, 1, 9}
