package pkixcmp2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

var X2009IdPasswordBasedMac = asn1.ObjectIdentifier{1, 2, 840, 113533, 7, 66, 13}
