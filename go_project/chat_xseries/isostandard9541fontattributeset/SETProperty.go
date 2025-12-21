package isostandard9541fontattributeset

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SETProperty struct {
    PropertyName SETGlobalName `asn1:"tag:0"`
    PropertyValue SETPropertyValue `asn1:"tag:1"`
}
