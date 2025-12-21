package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type CertificateExtensionsCertificateListExactAssertion struct {
    Issuer InformationFrameworkName
    ThisUpdate time.Time
    DistributionPoint CertificateExtensionsDistributionPointName `asn1:"optional"`
}
