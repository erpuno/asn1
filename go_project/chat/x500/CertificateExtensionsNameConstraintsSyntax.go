package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type CertificateExtensionsNameConstraintsSyntax struct {
    PermittedSubtrees CertificateExtensionsGeneralSubtrees `asn1:"optional,tag:0"`
    ExcludedSubtrees CertificateExtensionsGeneralSubtrees `asn1:"optional,tag:1"`
    RequiredNameForms CertificateExtensionsNameForms `asn1:"optional,tag:2"`
}
