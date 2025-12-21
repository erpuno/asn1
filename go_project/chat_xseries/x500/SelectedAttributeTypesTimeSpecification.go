package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SelectedAttributeTypesTimeSpecification struct {
    Time asn1.RawValue
    NotThisTime bool
    TimeZone SelectedAttributeTypesTimeZone `asn1:"optional"`
}
