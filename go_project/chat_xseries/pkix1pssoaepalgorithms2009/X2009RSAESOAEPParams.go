package pkix1pssoaepalgorithms2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009RSAESOAEPParams struct {
    HashFunc X2009HashAlgorithm `asn1:"tag:0"`
    MaskGenFunc X2009MaskGenAlgorithm `asn1:"tag:1"`
    PSourceFunc X2009PSourceAlgorithm `asn1:"tag:2"`
}
