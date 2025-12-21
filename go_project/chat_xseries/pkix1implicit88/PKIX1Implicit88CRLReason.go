package pkix1implicit88

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type PKIX1Implicit88CRLReason int

const (
    PKIX1Implicit88CRLReasonUnspecified PKIX1Implicit88CRLReason = 0
    PKIX1Implicit88CRLReasonKeyCompromise PKIX1Implicit88CRLReason = 1
    PKIX1Implicit88CRLReasonCACompromise PKIX1Implicit88CRLReason = 2
    PKIX1Implicit88CRLReasonAffiliationChanged PKIX1Implicit88CRLReason = 3
    PKIX1Implicit88CRLReasonSuperseded PKIX1Implicit88CRLReason = 4
    PKIX1Implicit88CRLReasonCessationOfOperation PKIX1Implicit88CRLReason = 5
    PKIX1Implicit88CRLReasonCertificateHold PKIX1Implicit88CRLReason = 6
    PKIX1Implicit88CRLReasonRemoveFromCRL PKIX1Implicit88CRLReason = 8
    PKIX1Implicit88CRLReasonPrivilegeWithdrawn PKIX1Implicit88CRLReason = 9
    PKIX1Implicit88CRLReasonAACompromise PKIX1Implicit88CRLReason = 10
)

