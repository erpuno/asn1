package pkixalgs2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

var X2009EcdsaWithSHA1 = asn1.ObjectIdentifier{1, 2, 840, 10045, 4, 1}
