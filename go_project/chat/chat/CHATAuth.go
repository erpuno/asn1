package chat

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type CHATAuth struct {
    Session []byte
    Type CHATAuthType
    SmsCode []byte
    Cert []byte
    Challange []byte
    Push []byte
    Os CHATOS
    Nickname []byte
    Settings []CHATFeature
    Token []byte
    Devkey []byte
    Phone []byte
}
