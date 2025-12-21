package ansix962

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X62SpecifiedECDomainVersion int

const (
    X62SpecifiedECDomainVersionEcdpVer1 X62SpecifiedECDomainVersion = 1
    X62SpecifiedECDomainVersionEcdpVer2 X62SpecifiedECDomainVersion = 2
    X62SpecifiedECDomainVersionEcdpVer3 X62SpecifiedECDomainVersion = 3
)

