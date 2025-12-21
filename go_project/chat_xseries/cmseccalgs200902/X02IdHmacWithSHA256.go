package cmseccalgs200902

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

var X02IdHmacWithSHA256 = asn1.ObjectIdentifier{1, 2, 840, 113549, 2, 9}
