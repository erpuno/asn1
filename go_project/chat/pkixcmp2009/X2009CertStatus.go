package pkixcmp2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009CertStatus struct {
    CertHash []byte
    CertReqId int64
    StatusInfo X2009PKIStatusInfo `asn1:"optional"`
}
