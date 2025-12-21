package kep

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type KEPOcspResponsesID struct {
    OcspIdentifier KEPOcspIdentifier
    OcspRepHash KEPOtherHash `asn1:"optional"`
}
