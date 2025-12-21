package extendedsecurityservices2009

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/cryptographicmessagesyntax2009"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009Receipt struct {
    Version X2009ESSVersion
    ContentType cryptographicmessagesyntax2009.X2009ContentType
    SignedContentIdentifier X2009ContentIdentifier
    OriginatorSignatureValue []byte
}
