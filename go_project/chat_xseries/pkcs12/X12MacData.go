package pkcs12

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/pkcs7"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X12MacData struct {
    Mac pkcs7.X7DigestInfo
    MacSalt []byte
    Iterations int64
}
