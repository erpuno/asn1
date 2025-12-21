package extendedsecurityservices2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009MLData struct {
    MailListIdentifier X2009EntityIdentifier
    ExpansionTime time.Time
    MlReceiptPolicy X2009MLReceiptPolicy `asn1:"optional"`
}
