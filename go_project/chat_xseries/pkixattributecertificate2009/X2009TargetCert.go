package pkixattributecertificate2009

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/pkix1implicit2009"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009TargetCert struct {
    TargetCertificate asn1.RawValue
    TargetName pkix1implicit2009.X2009GeneralName `asn1:"optional"`
    CertDigestInfo X2009ObjectDigestInfo `asn1:"optional"`
}
