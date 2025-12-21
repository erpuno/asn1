package cryptographicmessagesyntax2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009EncryptedData struct {
    Version X2009CMSVersion
    EncryptedContentInfo X2009EncryptedContentInfo
    UnprotectedAttrs asn1.RawValue `asn1:"optional,tag:1"`
}
