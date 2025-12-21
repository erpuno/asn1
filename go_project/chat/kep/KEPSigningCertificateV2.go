package kep

import (
    "encoding/asn1"
    "time"
    "tobirama/chat/x500"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type KEPSigningCertificateV2 struct {
    Certs []KEPESSCertIDv2
    Policies []x500.CertificateExtensionsPolicyInformation `asn1:"optional"`
}
