package pkixattributecertificate2009

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/pkix1implicit2009"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009ACClearAttrs struct {
    AcIssuer pkix1implicit2009.X2009GeneralName
    AcSerial int64
    Attrs []asn1.RawValue
}
