package cryptographicmessagesyntax2010

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2010ExtendedCertificateInfo struct {
    Version X2010CMSVersion
    Certificate asn1.RawValue
    Attributes X2010UnauthAttributes `asn1:"set"`
}
