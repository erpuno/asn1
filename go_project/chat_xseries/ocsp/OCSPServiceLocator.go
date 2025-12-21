package ocsp

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/pkix1explicit88"
    "tobirama/chat_xseries/pkix1implicit88"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type OCSPServiceLocator struct {
    Issuer pkix1explicit88.PKIX1Explicit88Name
    Locator pkix1implicit88.PKIX1Implicit88AuthorityInfoAccessSyntax
}
