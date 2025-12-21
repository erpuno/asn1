package pkixcmp2009

import (
    "encoding/asn1"
    "time"
    "tobirama/chat/pkixcrmf2009"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009OOBCertHash struct {
    HashAlg asn1.RawValue `asn1:"optional,tag:0"`
    CertId pkixcrmf2009.X2009CertId `asn1:"optional,tag:1"`
    HashVal asn1.BitString
}
