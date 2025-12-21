package cryptographicmessagesyntax2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009KeyTransRecipientInfo struct {
    Version X2009CMSVersion
    Rid X2009RecipientIdentifier
    KeyEncryptionAlgorithm asn1.RawValue
    EncryptedKey X2009EncryptedKey
}
