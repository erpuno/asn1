package pkixcrmf2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009POPOSigningKeyInput struct {
    AuthInfo asn1.RawValue
    PublicKey asn1.RawValue
}
