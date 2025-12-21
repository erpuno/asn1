package isostandard9541fontattributeset

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SETDataVersion struct {
    Major SETCardinal `asn1:"optional,tag:0"`
    Minor SETCardinal `asn1:"optional,tag:1"`
    Timestamp time.Time `asn1:"optional,tag:2"`
}
