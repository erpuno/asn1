package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type CertificateExtensionsGeneralSubtree struct {
    Base CertificateExtensionsGeneralName
    Minimum CertificateExtensionsBaseDistance `asn1:"tag:0"`
    Maximum CertificateExtensionsBaseDistance `asn1:"optional,tag:1"`
}
