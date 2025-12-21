package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SelectedAttributeTypesDayTime struct {
    Hour int64 `asn1:"tag:0"`
    Minute int64 `asn1:"tag:1"`
    Second int64 `asn1:"tag:2"`
}
