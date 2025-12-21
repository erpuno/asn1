package smimesymmetrickeydistribution2009

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/pkix1implicit2009"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009GLRekey struct {
    GlName pkix1implicit2009.X2009GeneralName
    GlAdministration X2009GLAdministration `asn1:"optional"`
    GlNewKeyAttributes X2009GLNewKeyAttributes `asn1:"optional"`
    GlRekeyAllGLKeys bool `asn1:"optional"`
}
