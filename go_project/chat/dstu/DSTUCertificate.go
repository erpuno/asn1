package dstu

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DSTUCertificate struct {
    TbsCertificate DSTUTBSCertificate
    SignatureAlgorithm asn1.RawValue
    SignatureValue asn1.BitString
}
