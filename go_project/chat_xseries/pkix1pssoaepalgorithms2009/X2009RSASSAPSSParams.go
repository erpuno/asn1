package pkix1pssoaepalgorithms2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009RSASSAPSSParams struct {
    HashAlgorithm X2009HashAlgorithm `asn1:"tag:0"`
    MaskGenAlgorithm X2009MaskGenAlgorithm `asn1:"tag:1"`
    SaltLength int64 `asn1:"tag:2"`
    TrailerField int64 `asn1:"tag:3"`
}
