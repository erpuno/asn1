package pkixcmp2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009PKIMessage struct {
    Header X2009PKIHeader
    Body X2009PKIBody
    Protection X2009PKIProtection `asn1:"optional,tag:0"`
    ExtraCerts []X2009CMPCertificate `asn1:"optional,tag:1"`
}
