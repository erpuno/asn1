package cmsecdhalgs2017

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

var X2017SmimeAlg = asn1.ObjectIdentifier{1, 2, 840, 113549, 1, 9, 16, 3}
