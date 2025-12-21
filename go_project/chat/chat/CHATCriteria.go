package chat

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type CHATCriteria int

const (
    CHATCriteriaEqual CHATCriteria = 0
    CHATCriteriaNotEqual CHATCriteria = 1
    CHATCriteriaLike CHATCriteria = 2
)

