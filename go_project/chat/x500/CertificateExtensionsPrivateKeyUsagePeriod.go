package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type CertificateExtensionsPrivateKeyUsagePeriod struct {
    NotBefore time.Time `asn1:"optional,tag:0"`
    NotAfter time.Time `asn1:"optional,tag:1"`
}
