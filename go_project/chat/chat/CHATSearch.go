package chat

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type CHATSearch struct {
    Dn []byte
    Id []byte
    Field []byte
    Value []byte
    Criteria CHATCriteria
    Type CHATScope
    Status CHATSearchStatus
}
