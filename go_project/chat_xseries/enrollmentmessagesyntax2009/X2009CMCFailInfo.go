package enrollmentmessagesyntax2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009CMCFailInfo int

const (
    X2009CMCFailInfoBadAlg X2009CMCFailInfo = 0
    X2009CMCFailInfoBadMessageCheck X2009CMCFailInfo = 1
    X2009CMCFailInfoBadRequest X2009CMCFailInfo = 2
    X2009CMCFailInfoBadTime X2009CMCFailInfo = 3
    X2009CMCFailInfoBadCertId X2009CMCFailInfo = 4
    X2009CMCFailInfoUnsuportedExt X2009CMCFailInfo = 5
    X2009CMCFailInfoMustArchiveKeys X2009CMCFailInfo = 6
    X2009CMCFailInfoBadIdentity X2009CMCFailInfo = 7
    X2009CMCFailInfoPopRequired X2009CMCFailInfo = 8
    X2009CMCFailInfoPopFailed X2009CMCFailInfo = 9
    X2009CMCFailInfoNoKeyReuse X2009CMCFailInfo = 10
    X2009CMCFailInfoInternalCAError X2009CMCFailInfo = 11
    X2009CMCFailInfoTryLater X2009CMCFailInfo = 12
    X2009CMCFailInfoAuthDataFail X2009CMCFailInfo = 13
)

