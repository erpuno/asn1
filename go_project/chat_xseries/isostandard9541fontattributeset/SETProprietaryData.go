package isostandard9541fontattributeset

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SETProprietaryData struct {
    PropDataMessage SETMessage `asn1:"optional,tag:0"`
    PropDataKey []byte `asn1:"optional,tag:1"`
    PropData []byte `asn1:"tag:2"`
}
