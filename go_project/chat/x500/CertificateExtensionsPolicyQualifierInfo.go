package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type CertificateExtensionsPolicyQualifierInfo struct {
    PolicyQualifierId asn1.ObjectIdentifier
    Qualifier asn1.RawValue `asn1:"optional"`
}
