package cryptographicmessagesyntax2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009KeyAgreeRecipientInfo struct {
    Version X2009CMSVersion
    Originator X2009OriginatorIdentifierOrKey `asn1:"tag:0,explicit"`
    Ukm X2009UserKeyingMaterial `asn1:"optional,tag:1,explicit"`
    KeyEncryptionAlgorithm asn1.RawValue
    RecipientEncryptedKeys X2009RecipientEncryptedKeys
}
