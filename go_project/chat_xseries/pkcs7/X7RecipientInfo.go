package pkcs7

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X7RecipientInfo struct {
    Version int64
    IssuerAndSerialNumber X7IssuerAndSerialNumber
    KeyEncryptionAlgorithm X7KeyEncryptionAlgorithmIdentifier
    EncryptedKey X7EncryptedKey
}
