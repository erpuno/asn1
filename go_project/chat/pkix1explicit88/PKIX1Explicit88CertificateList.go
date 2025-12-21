package pkix1explicit88

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type PKIX1Explicit88CertificateList struct {
    TbsCertList PKIX1Explicit88TBSCertList
    SignatureAlgorithm asn1.RawValue
    Signature asn1.BitString
}
