package pkixx400address2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009PDSParameter struct {
    PrintableString string `asn1:"optional"`
    TeletexString asn1.RawValue `asn1:"optional"`
}
