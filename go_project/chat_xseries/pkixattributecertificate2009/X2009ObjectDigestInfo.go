package pkixattributecertificate2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009ObjectDigestInfo struct {
    DigestedObjectType int
    OtherObjectTypeID asn1.ObjectIdentifier `asn1:"optional"`
    DigestAlgorithm asn1.RawValue
    ObjectDigest asn1.BitString
}
