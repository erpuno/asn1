package kep

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type KEPRevocationValues struct {
    CrlVals []asn1.RawValue `asn1:"optional,tag:0"`
    OcspVals []KEPBasicOCSPResponse `asn1:"optional,tag:1"`
    OtherRevVals KEPOtherRevVals `asn1:"optional,tag:2"`
}
