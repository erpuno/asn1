package pkcs12

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/pkcs7"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X12PFX struct {
    Version int64
    AuthSafe pkcs7.X7ContentInfo
    MacData X12MacData `asn1:"optional"`
}
