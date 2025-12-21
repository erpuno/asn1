package cryptographicmessagesyntax2010

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2010EncryptedContentInfo struct {
    ContentType asn1.ObjectIdentifier
    ContentEncryptionAlgorithm X2009AlgorithmIdentifier
    EncryptedContent []byte `asn1:"optional,tag:0"`
}
