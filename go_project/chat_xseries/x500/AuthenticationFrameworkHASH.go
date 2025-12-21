package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AuthenticationFrameworkHASH struct {
    AlgorithmIdentifier asn1.RawValue
    HashValue asn1.BitString
}
