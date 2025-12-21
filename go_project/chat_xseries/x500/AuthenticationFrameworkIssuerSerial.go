package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AuthenticationFrameworkIssuerSerial struct {
    Issuer asn1.RawValue
    Serial AuthenticationFrameworkCertificateSerialNumber
    IssuerUID SelectedAttributeTypesUniqueIdentifier `asn1:"optional"`
}
