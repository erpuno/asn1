package smimesymmetrickeydistribution2009

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/cryptographicmessagesyntax2009"
    "tobirama/chat_xseries/pkix1implicit2009"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009GLKey struct {
    GlName pkix1implicit2009.X2009GeneralName
    GlIdentifier cryptographicmessagesyntax2009.X2009KEKIdentifier
    GlkWrapped cryptographicmessagesyntax2009.X2009RecipientInfos `asn1:"set"`
    GlkAlgorithm X2009KeyWrapAlgorithm
    GlkNotBefore time.Time
    GlkNotAfter time.Time
}
