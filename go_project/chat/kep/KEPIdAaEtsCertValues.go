package kep

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

var KEPIdAaEtsCertValues = asn1.ObjectIdentifier{1, 2, 840, 113549, 1, 9, 16, 2, 23}
