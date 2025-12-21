package isostandard9541fontattributeset

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SETAlignmentSpacing struct {
    MinlinespLeft SETRelRational `asn1:"tag:0"`
    MinlinespRight SETRelRational `asn1:"tag:1"`
}
