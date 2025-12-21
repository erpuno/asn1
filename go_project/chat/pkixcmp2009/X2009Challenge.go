package pkixcmp2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009Challenge struct {
    Owf asn1.RawValue `asn1:"optional"`
    Witness []byte
    Challenge []byte
}
