package cryptographicmessagesyntax2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009AuthenticatedData struct {
    Version X2009CMSVersion
    OriginatorInfo X2009OriginatorInfo `asn1:"optional,tag:0"`
    RecipientInfos X2009RecipientInfos `asn1:"set"`
    MacAlgorithm X2009MessageAuthenticationCodeAlgorithm
    DigestAlgorithm X2009DigestAlgorithmIdentifier `asn1:"optional,tag:1"`
    EncapContentInfo X2009EncapsulatedContentInfo
    AuthAttrs X2009AuthAttributes `asn1:"optional,set,tag:2"`
    Mac X2009MessageAuthenticationCode
    UnauthAttrs X2009UnauthAttributes `asn1:"optional,set,tag:3"`
}
