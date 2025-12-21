package pkcs12

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/pkcs8"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X12PKCS8ShroudedKeyBag pkcs8.X8EncryptedPrivateKeyInfo