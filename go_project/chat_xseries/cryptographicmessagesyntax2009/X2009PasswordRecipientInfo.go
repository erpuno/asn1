package cryptographicmessagesyntax2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009PasswordRecipientInfo struct {
    Version X2009CMSVersion
    KeyDerivationAlgorithm X2009KeyDerivationAlgorithmIdentifier `asn1:"optional,tag:0"`
    KeyEncryptionAlgorithm X2009KeyEncryptionAlgorithmIdentifier
    EncryptedKey X2009EncryptedKey
}
