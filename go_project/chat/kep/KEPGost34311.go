package kep

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

var KEPGost34311 = asn1.ObjectIdentifier{1, 2, 804, 2, 1, 1, 1, 1, 2, 1}
