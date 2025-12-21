package chat

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type CHATServiceType int

const (
    CHATServiceTypeSynrc CHATServiceType = 0
    CHATServiceTypeAws CHATServiceType = 1
    CHATServiceTypeGcp CHATServiceType = 2
    CHATServiceTypeAzure CHATServiceType = 3
)

