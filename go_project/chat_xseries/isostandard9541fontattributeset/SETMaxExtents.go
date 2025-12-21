package isostandard9541fontattributeset

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SETMaxExtents struct {
    MaxMinx SETRelRational `asn1:"tag:0"`
    MaxMiny SETRelRational `asn1:"tag:1"`
    MaxMaxx SETRelRational `asn1:"tag:2"`
    MaxMaxy SETRelRational `asn1:"tag:3"`
}
