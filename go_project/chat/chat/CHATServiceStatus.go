package chat

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type CHATServiceStatus int

const (
    CHATServiceStatusVerified CHATServiceStatus = 0
    CHATServiceStatusAdded CHATServiceStatus = 1
    CHATServiceStatusAdd CHATServiceStatus = 2
    CHATServiceStatusRemove CHATServiceStatus = 3
)

