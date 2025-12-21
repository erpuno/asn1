package pkixcrmf2009

import (
    "encoding/asn1"
    "time"
    "tobirama/chat/pkix1implicit2009"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009CertId struct {
    Issuer pkix1implicit2009.X2009GeneralName
    SerialNumber int64
}
