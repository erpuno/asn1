package cryptographicmessagesyntax2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009EncapsulatedContentInfo struct {
    EContentType asn1.ObjectIdentifier
    EContent []byte `asn1:"optional,tag:0,explicit"`
}
