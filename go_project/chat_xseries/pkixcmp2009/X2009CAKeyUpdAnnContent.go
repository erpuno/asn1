package pkixcmp2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009CAKeyUpdAnnContent struct {
    OldWithNew X2009CMPCertificate
    NewWithOld X2009CMPCertificate
    NewWithNew X2009CMPCertificate
}
