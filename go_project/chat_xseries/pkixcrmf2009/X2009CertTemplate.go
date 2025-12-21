package pkixcrmf2009

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/pkix1explicit2009"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009CertTemplate struct {
    Version pkix1explicit2009.X2009Version `asn1:"optional,tag:0"`
    SerialNumber int64 `asn1:"optional,tag:1"`
    SigningAlg asn1.RawValue `asn1:"optional,tag:2"`
    Issuer pkix1explicit2009.X2009Name `asn1:"optional,tag:3"`
    Validity X2009OptionalValidity `asn1:"optional,tag:4"`
    Subject pkix1explicit2009.X2009Name `asn1:"optional,tag:5"`
    PublicKey asn1.RawValue `asn1:"optional,tag:6"`
    IssuerUID pkix1explicit2009.X2009UniqueIdentifier `asn1:"optional,tag:7"`
    SubjectUID pkix1explicit2009.X2009UniqueIdentifier `asn1:"optional,tag:8"`
    Extensions asn1.RawValue `asn1:"optional,tag:9"`
}
