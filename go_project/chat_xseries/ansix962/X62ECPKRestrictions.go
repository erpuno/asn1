package ansix962

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X62ECPKRestrictions struct {
    EcDomain X62ECDomainParameters
    EccAlgorithms X62ECCAlgorithms
}
