package pkixattributecertificate2009

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/pkix1explicit2009"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009AttributeCertificateInfo struct {
    Version X2009AttCertVersion
    Holder X2009Holder
    Issuer X2009AttCertIssuer
    Signature asn1.RawValue
    SerialNumber pkix1explicit2009.X2009CertificateSerialNumber
    AttrCertValidityPeriod X2009AttCertValidityPeriod
    Attributes []asn1.RawValue
    IssuerUniqueID pkix1explicit2009.X2009UniqueIdentifier `asn1:"optional"`
    Extensions asn1.RawValue `asn1:"optional"`
}
