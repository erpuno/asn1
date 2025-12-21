package pkixcmp2009

import (
    "encoding/asn1"
    "time"
    "tobirama/chat/pkixcrmf2009"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009RevAnnContent struct {
    Status X2009PKIStatus
    CertId pkixcrmf2009.X2009CertId
    WillBeRevokedAt time.Time
    BadSinceDate time.Time
    CrlDetails asn1.RawValue `asn1:"optional"`
}
