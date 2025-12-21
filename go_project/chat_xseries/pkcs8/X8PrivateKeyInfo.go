package pkcs8

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X8PrivateKeyInfo struct {
    Version X8Version
    PrivateKeyAlgorithm asn1.RawValue
    PrivateKey X8PrivateKey
    Attributes X8Attributes `asn1:"optional,set,tag:0"`
}
