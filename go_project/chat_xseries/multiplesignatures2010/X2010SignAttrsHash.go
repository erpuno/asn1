package multiplesignatures2010

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/cryptographicmessagesyntax2010"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2010SignAttrsHash struct {
    AlgID cryptographicmessagesyntax2010.X2010DigestAlgorithmIdentifier
    Hash []byte
}
