package pkcs9

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

var X9Pkcs9AtUserPKCS12 = asn1.ObjectIdentifier{2, 16, 840, 1, 113730, 3, 1, 216}
