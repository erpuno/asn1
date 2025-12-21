package attributecertificateversion12009

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/pkix1explicit2009"
    "tobirama/chat_xseries/pkixattributecertificate2009"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009AttributeCertificateInfoV1 struct {
    Version X2009AttCertVersionV1
    Subject asn1.RawValue
    Issuer asn1.RawValue
    Signature asn1.RawValue
    SerialNumber pkix1explicit2009.X2009CertificateSerialNumber
    AttCertValidityPeriod pkixattributecertificate2009.X2009AttCertValidityPeriod
    Attributes []asn1.RawValue
    IssuerUniqueID pkix1explicit2009.X2009UniqueIdentifier `asn1:"optional"`
    Extensions asn1.RawValue `asn1:"optional"`
}
