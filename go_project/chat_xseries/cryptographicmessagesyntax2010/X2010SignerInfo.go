package cryptographicmessagesyntax2010

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2010SignerInfo struct {
    Version X2010CMSVersion
    Sid X2010SignerIdentifier
    DigestAlgorithm X2010DigestAlgorithmIdentifier
    SignedAttrs X2010SignedAttributes `asn1:"optional,tag:0"`
    SignatureAlgorithm X2010SignatureAlgorithmIdentifier
    Signature X2010SignatureValue
    UnsignedAttrs asn1.RawValue `asn1:"optional,tag:1"`
}
