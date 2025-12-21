package cryptographicmessagesyntax2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009DigestedData struct {
    Version X2009CMSVersion
    DigestAlgorithm X2009DigestAlgorithmIdentifier
    EncapContentInfo X2009EncapsulatedContentInfo
    Digest X2009Digest
}
