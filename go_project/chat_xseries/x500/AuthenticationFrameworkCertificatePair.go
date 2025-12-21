package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AuthenticationFrameworkCertificatePair struct {
    IssuedByThisCA asn1.RawValue `asn1:"optional,tag:0"`
    IssuedToThisCA asn1.RawValue `asn1:"optional,tag:1"`
}
