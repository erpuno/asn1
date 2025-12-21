package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SelectedAttributeTypesDayTimeBand struct {
    StartDayTime SelectedAttributeTypesDayTime `asn1:"tag:0"`
    EndDayTime SelectedAttributeTypesDayTime `asn1:"tag:1"`
}
