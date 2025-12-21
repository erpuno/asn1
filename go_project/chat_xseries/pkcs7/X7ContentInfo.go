package pkcs7

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X7ContentInfo struct {
    ContentType X7ContentType
    Content asn1.RawValue `asn1:"optional,tag:0,explicit"`
}
