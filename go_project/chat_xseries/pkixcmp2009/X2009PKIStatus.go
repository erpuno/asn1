package pkixcmp2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009PKIStatus int

const (
    X2009PKIStatusAccepted X2009PKIStatus = 0
    X2009PKIStatusGrantedWithMods X2009PKIStatus = 1
    X2009PKIStatusRejection X2009PKIStatus = 2
    X2009PKIStatusWaiting X2009PKIStatus = 3
    X2009PKIStatusRevocationWarning X2009PKIStatus = 4
    X2009PKIStatusRevocationNotification X2009PKIStatus = 5
    X2009PKIStatusKeyUpdateWarning X2009PKIStatus = 6
)

