package pkixcrmf2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009CertReqMsg struct {
    CertReq X2009CertRequest
    Popo X2009ProofOfPossession `asn1:"optional"`
    RegInfo []asn1.RawValue `asn1:"optional"`
}
