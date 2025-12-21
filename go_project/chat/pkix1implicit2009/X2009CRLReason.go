package pkix1implicit2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009CRLReason int

const (
    X2009CRLReasonUnspecified X2009CRLReason = 0
    X2009CRLReasonKeyCompromise X2009CRLReason = 1
    X2009CRLReasonCACompromise X2009CRLReason = 2
    X2009CRLReasonAffiliationChanged X2009CRLReason = 3
    X2009CRLReasonSuperseded X2009CRLReason = 4
    X2009CRLReasonCessationOfOperation X2009CRLReason = 5
    X2009CRLReasonCertificateHold X2009CRLReason = 6
    X2009CRLReasonRemoveFromCRL X2009CRLReason = 8
    X2009CRLReasonPrivilegeWithdrawn X2009CRLReason = 9
    X2009CRLReasonAACompromise X2009CRLReason = 10
)

