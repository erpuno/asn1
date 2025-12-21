package pkix1implicit2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009IssuingDistributionPoint struct {
    DistributionPoint X2009DistributionPointName `asn1:"optional,tag:0"`
    OnlyContainsUserCerts bool `asn1:"tag:1"`
    OnlyContainsCACerts bool `asn1:"tag:2"`
    OnlySomeReasons X2009ReasonFlags `asn1:"optional,tag:3"`
    IndirectCRL bool `asn1:"tag:4"`
    OnlyContainsAttributeCerts bool `asn1:"tag:5"`
}
