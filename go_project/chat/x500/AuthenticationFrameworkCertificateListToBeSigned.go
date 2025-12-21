package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AuthenticationFrameworkCertificateListToBeSigned struct {
    Version AuthenticationFrameworkVersion `asn1:"optional"`
    Signature asn1.RawValue
    Issuer InformationFrameworkName
    ThisUpdate time.Time
    NextUpdate time.Time `asn1:"optional"`
    RevokedCertificates []asn1.RawValue `asn1:"optional"`
    CrlExtensions AuthenticationFrameworkExtensions `asn1:"optional,tag:0"`
}
