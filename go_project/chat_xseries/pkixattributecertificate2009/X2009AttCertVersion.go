package pkixattributecertificate2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009AttCertVersion int

const (
    X2009AttCertVersionV2 X2009AttCertVersion = 1
)

