package cryptographicmessagesyntax2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009SignerInfo struct {
    Version X2009CMSVersion
    Sid X2009SignerIdentifier
    DigestAlgorithm X2009DigestAlgorithmIdentifier
    SignedAttrs X2009SignedAttributes `asn1:"optional,tag:0"`
    SignatureAlgorithm X2009SignatureAlgorithmIdentifier
    Signature X2009SignatureValue
    UnsignedAttrs asn1.RawValue `asn1:"optional,tag:1"`
}
