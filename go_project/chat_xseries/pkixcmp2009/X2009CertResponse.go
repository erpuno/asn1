package pkixcmp2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009CertResponse struct {
    CertReqId int64
    Status X2009PKIStatusInfo
    CertifiedKeyPair X2009CertifiedKeyPair `asn1:"optional"`
    RspInfo []byte `asn1:"optional"`
}
