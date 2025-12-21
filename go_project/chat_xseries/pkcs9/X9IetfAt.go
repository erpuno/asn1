package pkcs9

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

var X9IetfAt = asn1.ObjectIdentifier{1, 3, 6, 1, 5, 5, 7, 9}
