package pkixcmp2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009PollRepContentElement struct {
    CertReqId int64
    CheckAfter int64
    Reason X2009PKIFreeText `asn1:"optional"`
}
