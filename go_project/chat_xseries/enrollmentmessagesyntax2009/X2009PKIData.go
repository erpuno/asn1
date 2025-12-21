package enrollmentmessagesyntax2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009PKIData struct {
    ControlSequence []X2009TaggedAttribute
    ReqSequence []X2009TaggedRequest
    CmsSequence []X2009TaggedContentInfo
    OtherMsgSequence []X2009OtherMsg
}
