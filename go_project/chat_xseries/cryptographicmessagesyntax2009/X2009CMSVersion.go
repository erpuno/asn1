package cryptographicmessagesyntax2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009CMSVersion int

const (
    X2009CMSVersionV0 X2009CMSVersion = 0
    X2009CMSVersionV1 X2009CMSVersion = 1
    X2009CMSVersionV2 X2009CMSVersion = 2
    X2009CMSVersionV3 X2009CMSVersion = 3
    X2009CMSVersionV4 X2009CMSVersion = 4
    X2009CMSVersionV5 X2009CMSVersion = 5
)

