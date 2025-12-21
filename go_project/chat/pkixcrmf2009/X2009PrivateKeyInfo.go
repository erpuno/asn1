package pkixcrmf2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009PrivateKeyInfo struct {
    Version int64
    PrivateKeyAlgorithm asn1.RawValue
    PrivateKey []byte
    Attributes X2009Attributes `asn1:"optional,set,tag:0"`
}
