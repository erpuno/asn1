package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type CertificateExtensionsCertificateListAssertion struct {
    Issuer InformationFrameworkName `asn1:"optional"`
    MinCRLNumber CertificateExtensionsCRLNumber `asn1:"optional,tag:0"`
    MaxCRLNumber CertificateExtensionsCRLNumber `asn1:"optional,tag:1"`
    ReasonFlags CertificateExtensionsReasonFlags `asn1:"optional"`
    DateAndTime time.Time `asn1:"optional"`
    DistributionPoint CertificateExtensionsDistributionPointName `asn1:"optional,tag:2"`
}
