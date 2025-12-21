package pkixcrmf2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SingleAttribute struct {
    Type asn1.ObjectIdentifier
    Value ASN1Any
}

