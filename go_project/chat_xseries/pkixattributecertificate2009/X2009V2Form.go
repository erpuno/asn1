package pkixattributecertificate2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009V2Form struct {
    IssuerName asn1.RawValue `asn1:"optional"`
    BaseCertificateID asn1.RawValue `asn1:"optional,tag:0"`
    ObjectDigestInfo X2009ObjectDigestInfo `asn1:"optional,tag:1"`
}
