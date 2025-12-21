package pkcs12

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

var X12PbeWithSHAAnd2KeyTripleDESCBC = asn1.ObjectIdentifier{4}
