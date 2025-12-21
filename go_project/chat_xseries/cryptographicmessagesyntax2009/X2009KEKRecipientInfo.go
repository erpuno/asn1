package cryptographicmessagesyntax2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009KEKRecipientInfo struct {
    Version X2009CMSVersion
    Kekid X2009KEKIdentifier
    KeyEncryptionAlgorithm X2009KeyEncryptionAlgorithmIdentifier
    EncryptedKey X2009EncryptedKey
}
