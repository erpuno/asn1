package cryptographicmessagesyntax2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009EnvelopedData struct {
    Version X2009CMSVersion
    OriginatorInfo X2009OriginatorInfo `asn1:"optional,tag:0"`
    RecipientInfos X2009RecipientInfos `asn1:"set"`
    EncryptedContentInfo X2009EncryptedContentInfo
    UnprotectedAttrs asn1.RawValue `asn1:"optional,tag:1"`
}
