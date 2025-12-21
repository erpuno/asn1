package cryptographicmessagesyntax2010

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2010DigestedData struct {
    Version X2010CMSVersion
    DigestAlgorithm X2010DigestAlgorithmIdentifier
    EncapContentInfo X2010EncapsulatedContentInfo
    Digest X2010Digest
}
