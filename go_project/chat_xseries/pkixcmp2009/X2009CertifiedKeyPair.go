package pkixcmp2009

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/pkixcrmf2009"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009CertifiedKeyPair struct {
    CertOrEncCert X2009CertOrEncCert
    PrivateKey pkixcrmf2009.X2009EncryptedValue `asn1:"optional,tag:0"`
    PublicationInfo pkixcrmf2009.X2009PKIPublicationInfo `asn1:"optional,tag:1"`
}
