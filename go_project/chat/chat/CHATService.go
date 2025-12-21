package chat

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type CHATService struct {
    Id []byte
    Type CHATServiceType
    Data []byte
    Login []byte
    Password []byte
    Expiration int64
    Status CHATServiceStatus
}
