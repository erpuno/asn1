package cryptographicmessagesyntax2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009ExtendedCertificateInfo struct {
    Version X2009CMSVersion
    Certificate asn1.RawValue
    Attributes X2009UnauthAttributes `asn1:"set"`
}
