package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type CertificateExtensionsCertificatePairExactAssertion struct {
    ForwardAssertion CertificateExtensionsCertificateExactAssertion `asn1:"optional,tag:0"`
    ReverseAssertion CertificateExtensionsCertificateExactAssertion `asn1:"optional,tag:1"`
}
