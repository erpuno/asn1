package cryptographicmessagesyntax2010

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2010KeyAgreeRecipientInfo struct {
    Version X2010CMSVersion
    Originator X2010OriginatorIdentifierOrKey `asn1:"tag:0,explicit"`
    Ukm X2010UserKeyingMaterial `asn1:"optional,tag:1,explicit"`
    KeyEncryptionAlgorithm asn1.RawValue
    RecipientEncryptedKeys X2010RecipientEncryptedKeys
}
