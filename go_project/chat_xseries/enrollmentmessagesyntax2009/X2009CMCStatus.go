package enrollmentmessagesyntax2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009CMCStatus int

const (
    X2009CMCStatusSuccess X2009CMCStatus = 0
    X2009CMCStatusFailed X2009CMCStatus = 2
    X2009CMCStatusPending X2009CMCStatus = 3
    X2009CMCStatusNoSupport X2009CMCStatus = 4
    X2009CMCStatusConfirmRequired X2009CMCStatus = 5
    X2009CMCStatusPopRequired X2009CMCStatus = 6
    X2009CMCStatusPartial X2009CMCStatus = 7
)

