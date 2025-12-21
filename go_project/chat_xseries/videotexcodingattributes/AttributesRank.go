package videotexcodingattributes

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesRank int

const (
    AttributesRankUndefined AttributesRank = 0
    AttributesRankRank1 AttributesRank = 1
    AttributesRankRank2 AttributesRank = 2
    AttributesRankRank3 AttributesRank = 3
    AttributesRankRank4 AttributesRank = 4
    AttributesRankRank5 AttributesRank = 5
)

