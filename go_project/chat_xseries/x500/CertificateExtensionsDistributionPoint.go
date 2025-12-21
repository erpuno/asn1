package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type CertificateExtensionsDistributionPoint struct {
    DistributionPoint CertificateExtensionsDistributionPointName `asn1:"optional,tag:0"`
    Reasons CertificateExtensionsReasonFlags `asn1:"optional,tag:1"`
    CRLIssuer asn1.RawValue `asn1:"optional,tag:2"`
}
