package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DirectoryAbstractServiceSecurityParameters struct {
    CertificationPath AuthenticationFrameworkCertificationPath `asn1:"optional,tag:0"`
    Name InformationFrameworkDistinguishedName `asn1:"optional,tag:1"`
    Time time.Time `asn1:"optional,tag:2"`
    Random asn1.BitString `asn1:"optional,tag:3"`
    Target DirectoryAbstractServiceProtectionRequest `asn1:"optional,tag:4"`
    Response asn1.BitString `asn1:"optional,tag:5"`
    OperationCode DirectoryAbstractServiceCode `asn1:"optional,tag:6"`
    AttributeCertificationPath AuthenticationFrameworkAttributeCertificationPath `asn1:"optional,tag:7"`
    ErrorProtection DirectoryAbstractServiceErrorProtectionRequest `asn1:"optional,tag:8"`
    ErrorCode DirectoryAbstractServiceCode `asn1:"optional,tag:9"`
}
