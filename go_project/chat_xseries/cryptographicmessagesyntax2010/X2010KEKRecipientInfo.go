package cryptographicmessagesyntax2010

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2010KEKRecipientInfo struct {
    Version X2010CMSVersion
    Kekid X2010KEKIdentifier
    KeyEncryptionAlgorithm X2010KeyEncryptionAlgorithmIdentifier
    EncryptedKey X2010EncryptedKey
}
