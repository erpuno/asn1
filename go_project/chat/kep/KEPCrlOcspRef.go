package kep

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type KEPCrlOcspRef struct {
    Crlids KEPCRLListID `asn1:"optional,tag:0"`
    Ocspids KEPOcspListID `asn1:"optional,tag:1"`
    OtherRev KEPOtherRevRefs `asn1:"optional,tag:2"`
}
