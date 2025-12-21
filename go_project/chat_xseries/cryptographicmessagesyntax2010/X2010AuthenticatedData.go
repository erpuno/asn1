package cryptographicmessagesyntax2010

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2010AuthenticatedData struct {
    Version X2010CMSVersion
    OriginatorInfo X2010OriginatorInfo `asn1:"optional,tag:0"`
    RecipientInfos X2010RecipientInfos `asn1:"set"`
    MacAlgorithm X2010MessageAuthenticationCodeAlgorithm
    DigestAlgorithm X2010DigestAlgorithmIdentifier `asn1:"optional,tag:1"`
    EncapContentInfo X2010EncapsulatedContentInfo
    AuthAttrs X2010AuthAttributes `asn1:"optional,set,tag:2"`
    Mac X2010MessageAuthenticationCode
    UnauthAttrs X2010UnauthAttributes `asn1:"optional,set,tag:3"`
}
