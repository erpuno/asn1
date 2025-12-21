package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AuthenticationFrameworkCertificationPath struct {
    UserCertificate asn1.RawValue
    TheCACertificates []AuthenticationFrameworkCertificatePair `asn1:"optional"`
}
