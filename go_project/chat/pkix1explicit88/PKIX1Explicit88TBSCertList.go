package pkix1explicit88

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type PKIX1Explicit88TBSCertList struct {
    Version PKIX1Explicit88Version `asn1:"optional"`
    Signature asn1.RawValue
    Issuer PKIX1Explicit88Name
    ThisUpdate time.Time
    NextUpdate time.Time `asn1:"optional"`
    RevokedCertificates []asn1.RawValue `asn1:"optional"`
    CrlExtensions PKIX1Explicit88Extensions `asn1:"optional,tag:0"`
}
