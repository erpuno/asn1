package pkixcmp2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009DHBMParameter struct {
    Owf asn1.RawValue
    Mac asn1.RawValue
}
