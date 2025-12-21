package kep

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type KEPSignerInfo struct {
    Version KEPCMSVersion
    Sid KEPSignerIdentifier
    DigestAlgorithm KEPDigestAlgorithmIdentifier
    SignedAttrs KEPSignedAttributes `asn1:"optional,set,tag:0"`
    SignatureAlgorithm KEPSignatureAlgorithmIdentifier
    Signature []byte
    UnsignedAttrs KEPUnsignedAttributes `asn1:"optional,set,tag:1"`
}
