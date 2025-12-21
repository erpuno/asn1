package pkix1implicit88

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type PKIX1Implicit88NameConstraints struct {
    PermittedSubtrees PKIX1Implicit88GeneralSubtrees `asn1:"optional,tag:0"`
    ExcludedSubtrees PKIX1Implicit88GeneralSubtrees `asn1:"optional,tag:1"`
}
