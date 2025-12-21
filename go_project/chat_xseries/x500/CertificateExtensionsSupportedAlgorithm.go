package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type CertificateExtensionsSupportedAlgorithm struct {
    AlgorithmIdentifier asn1.RawValue
    IntendedUsage CertificateExtensionsKeyUsage `asn1:"optional,tag:0"`
    IntendedCertificatePolicies CertificateExtensionsCertificatePoliciesSyntax `asn1:"optional,tag:1"`
}
