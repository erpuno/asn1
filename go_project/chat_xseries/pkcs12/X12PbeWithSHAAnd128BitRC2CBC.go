package pkcs12

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

var X12PbeWithSHAAnd128BitRC2CBC = asn1.ObjectIdentifier{5}
