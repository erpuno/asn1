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

type X2009RevokeRequest struct {
    IssuerName pkix1explicit2009.X2009Name
    SerialNumber int64
    Reason pkix1implicit2009.X2009CRLReason
    InvalidityDate time.Time `asn1:"optional"`
    Passphrase []byte `asn1:"optional"`
    Comment string `asn1:"optional"`
}
