package pkix1implicit2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009NameConstraints struct {
    PermittedSubtrees X2009GeneralSubtrees `asn1:"optional,tag:0"`
    ExcludedSubtrees X2009GeneralSubtrees `asn1:"optional,tag:1"`
}
