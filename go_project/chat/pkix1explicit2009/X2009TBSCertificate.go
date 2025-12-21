package pkix1explicit2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009TBSCertificate struct {
    Version X2009Version `asn1:"tag:0"`
    SerialNumber X2009CertificateSerialNumber
    Signature asn1.RawValue
    Issuer X2009Name
    Validity X2009Validity
    Subject X2009Name
    SubjectPublicKeyInfo asn1.RawValue
    IssuerUniqueID X2009UniqueIdentifier `asn1:"optional,tag:1"`
    SubjectUniqueID X2009UniqueIdentifier `asn1:"optional,tag:2"`
    Extensions asn1.RawValue `asn1:"optional,tag:3"`
}
