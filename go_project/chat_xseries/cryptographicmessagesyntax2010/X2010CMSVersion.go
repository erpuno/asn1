package cryptographicmessagesyntax2010

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2010CMSVersion int

const (
    X2010CMSVersionV0 X2010CMSVersion = 0
    X2010CMSVersionV1 X2010CMSVersion = 1
    X2010CMSVersionV2 X2010CMSVersion = 2
    X2010CMSVersionV3 X2010CMSVersion = 3
    X2010CMSVersionV4 X2010CMSVersion = 4
    X2010CMSVersionV5 X2010CMSVersion = 5
)

