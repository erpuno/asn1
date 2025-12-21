package pkix1explicit88

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type PKIX1Explicit88TBSCertificate struct {
    Version PKIX1Explicit88Version `asn1:"tag:0"`
    SerialNumber PKIX1Explicit88CertificateSerialNumber
    Signature asn1.RawValue
    Issuer PKIX1Explicit88Name
    Validity PKIX1Explicit88Validity
    Subject PKIX1Explicit88Name
    SubjectPublicKeyInfo asn1.RawValue
    IssuerUniqueID PKIX1Explicit88UniqueIdentifier `asn1:"optional,tag:1"`
    SubjectUniqueID PKIX1Explicit88UniqueIdentifier `asn1:"optional,tag:2"`
    Extensions PKIX1Explicit88Extensions `asn1:"optional,tag:3"`
}
