package pkixcmp2009

import (
    "encoding/asn1"
    "time"
    "tobirama/chat/pkixcrmf2009"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009RevDetails struct {
    CertDetails pkixcrmf2009.X2009CertTemplate
    CrlEntryDetails asn1.RawValue `asn1:"optional"`
}
