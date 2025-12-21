package chat

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type CHATOS int

const (
    CHATOSApple CHATOS = 1
    CHATOSMicrosoft CHATOS = 2
    CHATOSGoogle CHATOS = 3
    CHATOSEricsson CHATOS = 4
)

