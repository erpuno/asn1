package pkixcrmf2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009POPOSigningKey struct {
    PoposkInput X2009POPOSigningKeyInput `asn1:"optional,tag:0"`
    AlgorithmIdentifier asn1.RawValue
    Signature asn1.BitString
}
