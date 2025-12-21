package pkcs7

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X7SignerInfo struct {
    Version int64
    IssuerAndSerialNumber X7IssuerAndSerialNumber
    DigestAlgorithm X7DigestAlgorithmIdentifier
    AuthenticatedAttributes asn1.RawValue `asn1:"optional"`
    DigestEncryptionAlgorithm X7DigestEncryptionAlgorithmIdentifier
    EncryptedDigest X7EncryptedDigest
    UnauthenticatedAttributes asn1.RawValue `asn1:"optional"`
}
