package pkix1explicit2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009TBSCertList struct {
    Version X2009Version `asn1:"optional"`
    Signature asn1.RawValue
    Issuer X2009Name
    ThisUpdate time.Time
    NextUpdate time.Time `asn1:"optional"`
    RevokedCertificates []asn1.RawValue `asn1:"optional"`
    CrlExtensions asn1.RawValue `asn1:"optional,tag:0"`
}
