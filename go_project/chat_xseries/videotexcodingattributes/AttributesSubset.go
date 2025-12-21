package videotexcodingattributes

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesSubset int

const (
    AttributesSubsetUndefined AttributesSubset = 0
    AttributesSubsetRank1 AttributesSubset = 1
    AttributesSubsetRank2 AttributesSubset = 2
    AttributesSubsetRank3 AttributesSubset = 3
    AttributesSubsetRank4 AttributesSubset = 4
    AttributesSubsetRank5 AttributesSubset = 5
    AttributesSubsetProfile1 AttributesSubset = 81
    AttributesSubsetProfile2 AttributesSubset = 82
    AttributesSubsetProfile3 AttributesSubset = 83
    AttributesSubsetProfile4 AttributesSubset = 84
    AttributesSubsetProfileX11 AttributesSubset = 85
    AttributesSubsetProfileX12 AttributesSubset = 86
    AttributesSubsetProfileX13 AttributesSubset = 87
    AttributesSubsetProfileX14 AttributesSubset = 88
    AttributesSubsetProfileX21 AttributesSubset = 89
    AttributesSubsetProfileX22 AttributesSubset = 90
    AttributesSubsetProfileX23 AttributesSubset = 91
    AttributesSubsetProfileX24 AttributesSubset = 92
)

