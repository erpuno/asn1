package pkixcmp2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009KeyRecRepContent struct {
    Status X2009PKIStatusInfo
    NewSigCert X2009CMPCertificate `asn1:"optional,tag:0"`
    CaCerts []X2009CMPCertificate `asn1:"optional,tag:1"`
    KeyPairHist []X2009CertifiedKeyPair `asn1:"optional,tag:2"`
}
