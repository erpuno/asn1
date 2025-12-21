package isostandard9541fontattributeset

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SETExtents struct {
    Minx SETRelRational `asn1:"optional,tag:0"`
    Miny SETRelRational `asn1:"optional,tag:1"`
    Maxx SETRelRational `asn1:"optional,tag:2"`
    Maxy SETRelRational `asn1:"optional,tag:3"`
}
