package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AuthenticationFrameworkACPathData struct {
    Certificate asn1.RawValue `asn1:"optional,tag:0"`
    AttributeCertificate AuthenticationFrameworkAttributeCertificate `asn1:"optional,tag:1"`
}
