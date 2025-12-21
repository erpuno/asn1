package kep

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type KEPBasicOCSPResponse struct {
    TbsResponseData KEPResponseData
    SignatureAlgorithm asn1.RawValue
    Signature asn1.BitString
    Certs []asn1.RawValue `asn1:"optional,tag:0,explicit"`
}
