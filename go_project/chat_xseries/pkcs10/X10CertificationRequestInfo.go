package pkcs10

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/pkix1explicit2009"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X10CertificationRequestInfo struct {
    Version int64
    Subject pkix1explicit2009.X2009Name
    SubjectPKInfo asn1.RawValue
    Attributes asn1.RawValue `asn1:"tag:0"`
}
