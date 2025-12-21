package cryptographicmessagesyntax2010

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2010EnvelopedData struct {
    Version X2010CMSVersion
    OriginatorInfo X2010OriginatorInfo `asn1:"optional,tag:0"`
    RecipientInfos X2010RecipientInfos `asn1:"set"`
    EncryptedContentInfo X2010EncryptedContentInfo
    UnprotectedAttrs asn1.RawValue `asn1:"optional,tag:1"`
}
