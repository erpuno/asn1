package aeskeywrapwithpad02

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

var X02IdAes128WrapPad = asn1.ObjectIdentifier{8}
