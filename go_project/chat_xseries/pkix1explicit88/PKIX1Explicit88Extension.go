package pkix1explicit88

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type PKIX1Explicit88Extension struct {
    ExtnID asn1.ObjectIdentifier
    Critical bool `asn1:"optional"`
    ExtnValue []byte
}
