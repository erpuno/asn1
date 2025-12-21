package kep

import (
    "encoding/asn1"
    "time"
    "tobirama/chat/x500"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type KEPTBSCertList struct {
    Version x500.AuthenticationFrameworkVersion `asn1:"optional"`
    Signature asn1.RawValue
    Issuer x500.InformationFrameworkName
    ThisUpdate time.Time
    NextUpdate time.Time `asn1:"optional"`
    RevokedCertificates []asn1.RawValue `asn1:"optional"`
    CrlExtensions x500.AuthenticationFrameworkExtensions `asn1:"optional,tag:0"`
}
