package ansix962

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X62SpecifiedECDomain struct {
    Version X62SpecifiedECDomainVersion
    FieldID asn1.RawValue
    Curve X62Curve
    Base X62ECPoint
    Order int64
    Cofactor int64 `asn1:"optional"`
    Hash X62HashAlgorithm `asn1:"optional"`
}
