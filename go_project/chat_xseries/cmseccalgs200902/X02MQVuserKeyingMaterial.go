package cmseccalgs200902

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/cryptographicmessagesyntax2009"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X02MQVuserKeyingMaterial struct {
    EphemeralPublicKey cryptographicmessagesyntax2009.X2009OriginatorPublicKey
    Addedukm cryptographicmessagesyntax2009.X2009UserKeyingMaterial `asn1:"optional,tag:0,explicit"`
}
