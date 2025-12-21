package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type CertificateExtensionsIssuingDistPointSyntax struct {
    DistributionPoint CertificateExtensionsDistributionPointName `asn1:"optional,tag:0"`
    OnlyContainsUserCerts bool `asn1:"tag:1"`
    OnlyContainsCACerts bool `asn1:"tag:2"`
    OnlySomeReasons CertificateExtensionsReasonFlags `asn1:"optional,tag:3"`
    IndirectCRL bool `asn1:"tag:4"`
}
