package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type CertificateExtensionsBasicConstraintsSyntax struct {
    CA bool
    PathLenConstraint int64 `asn1:"optional"`
}
