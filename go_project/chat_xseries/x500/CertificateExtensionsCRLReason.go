package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type CertificateExtensionsCRLReason int

const (
    CertificateExtensionsCRLReasonUnspecified CertificateExtensionsCRLReason = 0
    CertificateExtensionsCRLReasonKeyCompromise CertificateExtensionsCRLReason = 1
    CertificateExtensionsCRLReasonCACompromise CertificateExtensionsCRLReason = 2
    CertificateExtensionsCRLReasonAffiliationChanged CertificateExtensionsCRLReason = 3
    CertificateExtensionsCRLReasonSuperseded CertificateExtensionsCRLReason = 4
    CertificateExtensionsCRLReasonCessationOfOperation CertificateExtensionsCRLReason = 5
    CertificateExtensionsCRLReasonCertificateHold CertificateExtensionsCRLReason = 6
    CertificateExtensionsCRLReasonRemoveFromCRL CertificateExtensionsCRLReason = 8
)

