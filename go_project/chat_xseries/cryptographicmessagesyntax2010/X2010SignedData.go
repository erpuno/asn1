package cryptographicmessagesyntax2010

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2010SignedData struct {
    Version X2010CMSVersion
    DigestAlgorithms []X2010DigestAlgorithmIdentifier `asn1:"set"`
    EncapContentInfo X2010EncapsulatedContentInfo
    Certificates X2010CertificateSet `asn1:"optional,set,tag:0"`
    Crls X2010RevocationInfoChoices `asn1:"optional,set,tag:1"`
    SignerInfos X2010SignerInfos `asn1:"set"`
}
