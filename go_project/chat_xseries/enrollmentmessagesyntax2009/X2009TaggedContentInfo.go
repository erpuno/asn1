package enrollmentmessagesyntax2009

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/cryptographicmessagesyntax2009"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009TaggedContentInfo struct {
    BodyPartID X2009BodyPartID
    ContentInfo cryptographicmessagesyntax2009.X2009ContentInfo
}
