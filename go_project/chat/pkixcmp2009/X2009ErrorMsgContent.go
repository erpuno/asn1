package pkixcmp2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009ErrorMsgContent struct {
    PKIStatusInfo X2009PKIStatusInfo
    ErrorCode int64 `asn1:"optional"`
    ErrorDetails X2009PKIFreeText `asn1:"optional"`
}
