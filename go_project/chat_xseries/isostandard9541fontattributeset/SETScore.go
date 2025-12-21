package isostandard9541fontattributeset

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SETScore struct {
    IsoStandard9541Scorename SETGlobalName `asn1:"tag:0"`
    ScorePropertyList SETScoreProperties `asn1:"tag:1"`
}
