package cryptographicmessagesyntax2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009SignedData struct {
    Version X2009CMSVersion
    DigestAlgorithms []X2009DigestAlgorithmIdentifier `asn1:"set"`
    EncapContentInfo X2009EncapsulatedContentInfo
    Certificates X2009CertificateSet `asn1:"optional,set,tag:0"`
    Crls X2009RevocationInfoChoices `asn1:"optional,set,tag:1"`
    SignerInfos X2009SignerInfos `asn1:"set"`
}
