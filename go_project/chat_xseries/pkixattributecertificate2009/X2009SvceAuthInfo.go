package pkixattributecertificate2009

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/pkix1implicit2009"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009SvceAuthInfo struct {
    Service pkix1implicit2009.X2009GeneralName
    Ident pkix1implicit2009.X2009GeneralName
    AuthInfo []byte `asn1:"optional"`
}
