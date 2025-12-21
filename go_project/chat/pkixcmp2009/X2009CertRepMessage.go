package pkixcmp2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009CertRepMessage struct {
    CaPubs []X2009CMPCertificate `asn1:"optional,tag:1"`
    Response []X2009CertResponse
}
