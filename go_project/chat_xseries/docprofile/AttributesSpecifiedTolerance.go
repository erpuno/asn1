package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesSpecifiedTolerance struct {
    ToleranceValue AttributesRealOrInt `asn1:"tag:0"`
    ToleranceSpace int64 `asn1:"tag:1"`
}
