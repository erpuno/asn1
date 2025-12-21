package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type InformationFrameworkRelaxationPolicy struct {
    Basic InformationFrameworkMRMapping `asn1:"tag:0"`
    Tightenings []InformationFrameworkMRMapping `asn1:"optional,tag:1"`
    Relaxations []InformationFrameworkMRMapping `asn1:"optional,tag:2"`
    Maximum int64 `asn1:"optional,tag:3"`
    Minimum int64 `asn1:"tag:4"`
}
