package cryptographicmessagesyntax2010

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2010PasswordRecipientInfo struct {
    Version X2010CMSVersion
    KeyDerivationAlgorithm X2010KeyDerivationAlgorithmIdentifier `asn1:"optional,tag:0"`
    KeyEncryptionAlgorithm X2010KeyEncryptionAlgorithmIdentifier
    EncryptedKey X2010EncryptedKey
}
