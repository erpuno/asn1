package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type CertificateExtensionsAuthorityKeyIdentifier struct {
    KeyIdentifier CertificateExtensionsKeyIdentifier `asn1:"optional,tag:0"`
    AuthorityCertIssuer asn1.RawValue `asn1:"optional,tag:1"`
    AuthorityCertSerialNumber AuthenticationFrameworkCertificateSerialNumber `asn1:"optional,tag:2"`
}
