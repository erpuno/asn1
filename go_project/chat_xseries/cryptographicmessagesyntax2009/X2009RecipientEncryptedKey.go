package cryptographicmessagesyntax2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009RecipientEncryptedKey struct {
    Rid X2009KeyAgreeRecipientIdentifier
    EncryptedKey X2009EncryptedKey
}
