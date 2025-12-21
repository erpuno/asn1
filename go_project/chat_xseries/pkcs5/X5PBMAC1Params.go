package pkcs5

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X5PBMAC1Params struct {
    KeyDerivationFunc asn1.RawValue
    MessageAuthScheme asn1.RawValue
}
