package smimesymmetrickeydistribution2009

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/pkix1implicit2009"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009GLOwnerInfo struct {
    GlOwnerName pkix1implicit2009.X2009GeneralName
    GlOwnerAddress pkix1implicit2009.X2009GeneralName
    Certificates X2009Certificates `asn1:"optional"`
}
