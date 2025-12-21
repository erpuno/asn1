package chat

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type CHATAuthType int

const (
    CHATAuthTypeReg CHATAuthType = 1
    CHATAuthTypeAuth CHATAuthType = 2
    CHATAuthTypeForget CHATAuthType = 3
    CHATAuthTypeRenew CHATAuthType = 4
)

