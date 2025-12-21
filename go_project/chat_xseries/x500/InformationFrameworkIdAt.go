package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

var InformationFrameworkIdAt = asn1.ObjectIdentifier{2, 5, 4}
