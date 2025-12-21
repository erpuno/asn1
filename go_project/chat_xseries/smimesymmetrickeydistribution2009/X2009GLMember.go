package smimesymmetrickeydistribution2009

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/pkix1implicit2009"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009GLMember struct {
    GlMemberName pkix1implicit2009.X2009GeneralName
    GlMemberAddress pkix1implicit2009.X2009GeneralName `asn1:"optional"`
    Certificates X2009Certificates `asn1:"optional"`
}
