package pkixx400address2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009TeletexDomainDefinedAttribute struct {
    Type asn1.RawValue
    Value asn1.RawValue
}
