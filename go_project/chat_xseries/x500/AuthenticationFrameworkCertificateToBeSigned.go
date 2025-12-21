package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AuthenticationFrameworkCertificateToBeSigned struct {
    Version AuthenticationFrameworkVersion `asn1:"tag:0"`
    SerialNumber AuthenticationFrameworkCertificateSerialNumber
    Signature asn1.RawValue
    Issuer InformationFrameworkName
    Validity AuthenticationFrameworkValidity
    Subject InformationFrameworkName
    SubjectPublicKeyInfo asn1.RawValue
    IssuerUniqueIdentifier SelectedAttributeTypesUniqueIdentifier `asn1:"optional,tag:1"`
    SubjectUniqueIdentifier SelectedAttributeTypesUniqueIdentifier `asn1:"optional,tag:2"`
    Extensions AuthenticationFrameworkExtensions `asn1:"optional,tag:3"`
}
