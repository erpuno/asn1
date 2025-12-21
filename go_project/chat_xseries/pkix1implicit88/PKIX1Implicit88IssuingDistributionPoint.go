package pkix1implicit88

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type PKIX1Implicit88IssuingDistributionPoint struct {
    DistributionPoint PKIX1Implicit88DistributionPointName `asn1:"optional,tag:0"`
    OnlyContainsUserCerts bool `asn1:"tag:1"`
    OnlyContainsCACerts bool `asn1:"tag:2"`
    OnlySomeReasons PKIX1Implicit88ReasonFlags `asn1:"optional,tag:3"`
    IndirectCRL bool `asn1:"tag:4"`
    OnlyContainsAttributeCerts bool `asn1:"tag:5"`
}
