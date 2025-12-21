package enrollmentmessagesyntax2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009PublishTrustAnchors struct {
    SeqNumber int64
    HashAlgorithm asn1.RawValue
    AnchorHashes [][]byte
}
