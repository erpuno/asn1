package enrollmentmessagesyntax2009

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/cryptographicmessagesyntax2009"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009EncryptedPOP struct {
    Request X2009TaggedRequest
    Cms cryptographicmessagesyntax2009.X2009ContentInfo
    ThePOPAlgID asn1.RawValue
    WitnessAlgID asn1.RawValue
    Witness []byte
}
