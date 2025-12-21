package pkixcrmf2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009CertRequest struct {
    CertReqId int64
    CertTemplate X2009CertTemplate
    Controls X2009Controls `asn1:"optional"`
}
