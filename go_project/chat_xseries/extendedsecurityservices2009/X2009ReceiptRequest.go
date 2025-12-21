package extendedsecurityservices2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009ReceiptRequest struct {
    SignedContentIdentifier X2009ContentIdentifier
    ReceiptsFrom X2009ReceiptsFrom
    ReceiptsTo []asn1.RawValue
}
