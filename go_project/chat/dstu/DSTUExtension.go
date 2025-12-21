package dstu

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DSTUExtension struct {
    ExtnID asn1.ObjectIdentifier
    Critical bool `asn1:"optional"`
    ExtnValue []byte
}
