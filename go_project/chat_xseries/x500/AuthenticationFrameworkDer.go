package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

var AuthenticationFrameworkDer = asn1.ObjectIdentifier{2, 1, 2, 1}
