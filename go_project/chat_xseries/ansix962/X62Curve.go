package ansix962

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X62Curve struct {
    A X62FieldElement
    B X62FieldElement
    Seed asn1.BitString `asn1:"optional"`
}
