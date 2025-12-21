package enrollmentmessagesyntax2009

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/pkix1explicit2009"
    "tobirama/chat_xseries/pkix1implicit2009"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009GetCRL struct {
    IssuerName pkix1explicit2009.X2009Name
    CRLName pkix1implicit2009.X2009GeneralName `asn1:"optional"`
    Time time.Time `asn1:"optional"`
    Reasons pkix1implicit2009.X2009ReasonFlags `asn1:"optional"`
}
