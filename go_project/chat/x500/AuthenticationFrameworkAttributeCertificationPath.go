package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AuthenticationFrameworkAttributeCertificationPath struct {
    AttributeCertificate AuthenticationFrameworkAttributeCertificate
    AcPath []AuthenticationFrameworkACPathData `asn1:"optional"`
}
