package kep

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type KEPCertificateList struct {
    TbsCertList KEPTBSCertList
    SignatureAlgorithm asn1.RawValue
    Signature asn1.BitString
}
