package ansix962

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X62Pentanomial struct {
    K1 int64
    K2 int64
    K3 int64
}
