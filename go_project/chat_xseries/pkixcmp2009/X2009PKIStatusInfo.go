package pkixcmp2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009PKIStatusInfo struct {
    Status X2009PKIStatus
    StatusString X2009PKIFreeText `asn1:"optional"`
    FailInfo X2009PKIFailureInfo `asn1:"optional"`
}
