package pkcs9

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

var X9Pkcs9AtPkcs7PDU = asn1.ObjectIdentifier{5}
