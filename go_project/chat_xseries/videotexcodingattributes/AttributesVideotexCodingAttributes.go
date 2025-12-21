package videotexcodingattributes

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesVideotexCodingAttributes struct {
    Subset AttributesSubset `asn1:"optional,tag:0"`
    Rank AttributesRank `asn1:"optional,tag:1"`
    Profile AttributesProfile `asn1:"optional,tag:2"`
}
