package kep

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type KEPSignedData struct {
    Version KEPCMSVersion
    DigestAlgorithms KEPDigestAlgorithmIdentifiers `asn1:"set"`
    EncapContentInfo KEPEncapsulatedContentInfo
    Certificates KEPCertificateSet `asn1:"optional,set,tag:0"`
    Crls KEPRevocationInfoChoices `asn1:"optional,set,tag:1"`
    SignerInfos KEPSignerInfos `asn1:"set"`
}
