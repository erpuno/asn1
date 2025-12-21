package cryptographicmessagesyntax2010

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2010EncapsulatedContentInfo struct {
    EContentType asn1.ObjectIdentifier
    EContent []byte `asn1:"optional,tag:0,explicit"`
}
