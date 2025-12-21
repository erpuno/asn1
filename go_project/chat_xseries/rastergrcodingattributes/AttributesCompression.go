package rastergrcodingattributes

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesCompression int

const (
    AttributesCompressionUncompressed AttributesCompression = 0
    AttributesCompressionCompressed AttributesCompression = 1
)

