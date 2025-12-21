package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type CertificateExtensionsPolicyConstraintsSyntax struct {
    RequireExplicitPolicy CertificateExtensionsSkipCerts `asn1:"optional,tag:0"`
    InhibitPolicyMapping CertificateExtensionsSkipCerts `asn1:"optional,tag:1"`
}
