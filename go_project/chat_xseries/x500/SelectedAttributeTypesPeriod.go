package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SelectedAttributeTypesPeriod struct {
    TimesOfDay []SelectedAttributeTypesDayTimeBand `asn1:"optional,set,tag:0"`
    Days asn1.RawValue `asn1:"optional,tag:1"`
    Weeks asn1.RawValue `asn1:"optional,tag:2"`
    Months asn1.RawValue `asn1:"optional,tag:3"`
    Years []int64 `asn1:"optional,set,tag:4"`
}
