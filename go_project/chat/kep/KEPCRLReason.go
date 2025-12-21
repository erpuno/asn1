package kep

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type KEPCRLReason int

const (
    KEPCRLReasonUnspecified KEPCRLReason = 0
    KEPCRLReasonKeyCompromise KEPCRLReason = 1
    KEPCRLReasonCACompromise KEPCRLReason = 2
    KEPCRLReasonAffiliationChanged KEPCRLReason = 3
    KEPCRLReasonSuperseded KEPCRLReason = 4
    KEPCRLReasonCessationOfOperation KEPCRLReason = 5
    KEPCRLReasonCertificateHold KEPCRLReason = 6
    KEPCRLReasonRemoveFromCRL KEPCRLReason = 8
    KEPCRLReasonPrivilegeWithdrawn KEPCRLReason = 9
    KEPCRLReasonAACompromise KEPCRLReason = 10
)

