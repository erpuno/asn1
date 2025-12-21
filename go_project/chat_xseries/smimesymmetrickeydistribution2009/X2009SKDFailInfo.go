package smimesymmetrickeydistribution2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009SKDFailInfo int

const (
    X2009SKDFailInfoUnspecified X2009SKDFailInfo = 0
    X2009SKDFailInfoClosedGL X2009SKDFailInfo = 1
    X2009SKDFailInfoUnsupportedDuration X2009SKDFailInfo = 2
    X2009SKDFailInfoNoGLACertificate X2009SKDFailInfo = 3
    X2009SKDFailInfoInvalidCert X2009SKDFailInfo = 4
    X2009SKDFailInfoUnsupportedAlgorithm X2009SKDFailInfo = 5
    X2009SKDFailInfoNoGLONameMatch X2009SKDFailInfo = 6
    X2009SKDFailInfoInvalidGLName X2009SKDFailInfo = 7
    X2009SKDFailInfoNameAlreadyInUse X2009SKDFailInfo = 8
    X2009SKDFailInfoNoSpam X2009SKDFailInfo = 9
    X2009SKDFailInfoDeniedAccess X2009SKDFailInfo = 10
    X2009SKDFailInfoAlreadyAMember X2009SKDFailInfo = 11
    X2009SKDFailInfoNotAMember X2009SKDFailInfo = 12
    X2009SKDFailInfoAlreadyAnOwner X2009SKDFailInfo = 13
    X2009SKDFailInfoNotAnOwner X2009SKDFailInfo = 14
)

