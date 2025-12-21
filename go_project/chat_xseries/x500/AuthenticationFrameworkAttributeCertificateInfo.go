package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AuthenticationFrameworkAttributeCertificateInfo struct {
    Version AuthenticationFrameworkVersion
    Subject asn1.RawValue
    Issuer asn1.RawValue
    Signature asn1.RawValue
    SerialNumber AuthenticationFrameworkCertificateSerialNumber
    AttCertValidityPeriod AuthenticationFrameworkAttCertValidityPeriod
    Attributes []asn1.RawValue
    IssuerUniqueID SelectedAttributeTypesUniqueIdentifier `asn1:"optional"`
    Extensions AuthenticationFrameworkExtensions `asn1:"optional"`
}
