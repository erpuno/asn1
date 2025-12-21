package cryptographicmessagesyntax2010

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2010KeyTransRecipientInfo struct {
    Version X2010CMSVersion
    Rid X2010RecipientIdentifier
    KeyEncryptionAlgorithm asn1.RawValue
    EncryptedKey X2010EncryptedKey
}
