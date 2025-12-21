package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AuthenticationFrameworkAttributeCertificateAssertion struct {
    Subject asn1.RawValue `asn1:"optional,tag:0"`
    Issuer InformationFrameworkName `asn1:"optional,tag:1"`
    AttCertValidity time.Time `asn1:"optional,tag:2"`
    AttType []asn1.ObjectIdentifier `asn1:"optional,set,tag:3"`
}
