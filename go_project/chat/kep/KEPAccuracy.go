package kep

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type KEPAccuracy struct {
    Seconds int64 `asn1:"optional"`
    Millis int64 `asn1:"optional,tag:0"`
    Micros int64 `asn1:"optional,tag:1"`
}
