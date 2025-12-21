package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type CertificateExtensionsCertificateAssertion struct {
    SerialNumber AuthenticationFrameworkCertificateSerialNumber `asn1:"optional,tag:0"`
    Issuer InformationFrameworkName `asn1:"optional,tag:1"`
    SubjectKeyIdentifier CertificateExtensionsSubjectKeyIdentifier `asn1:"optional,tag:2"`
    AuthorityKeyIdentifier CertificateExtensionsAuthorityKeyIdentifier `asn1:"optional,tag:3"`
    CertificateValid time.Time `asn1:"optional,tag:4"`
    PrivateKeyValid time.Time `asn1:"optional,tag:5"`
    SubjectPublicKeyAlgID asn1.ObjectIdentifier `asn1:"optional,tag:6"`
    KeyUsage CertificateExtensionsKeyUsage `asn1:"optional,tag:7"`
    SubjectAltName CertificateExtensionsAltNameType `asn1:"optional,tag:8"`
    Policy CertificateExtensionsCertPolicySet `asn1:"optional,tag:9"`
    PathToName InformationFrameworkName `asn1:"optional,tag:10"`
}
