package pkix1implicit2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

var X2009HoldInstruction = asn1.ObjectIdentifier{2, 2, 840, 10040, 2}
