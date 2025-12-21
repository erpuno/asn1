package extendedsecurityservices2009

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/cryptographicmessagesyntax2009"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009ContentHints struct {
    ContentDescription string `asn1:"optional"`
    ContentType cryptographicmessagesyntax2009.X2009ContentType
}
