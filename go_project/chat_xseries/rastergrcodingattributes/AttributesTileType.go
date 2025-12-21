package rastergrcodingattributes

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesTileType int

const (
    AttributesTileTypeNullBackground AttributesTileType = 0
    AttributesTileTypeNullForeground AttributesTileType = 1
    AttributesTileTypeT6Encoded AttributesTileType = 2
    AttributesTileTypeT4OneDimensionalEncoded AttributesTileType = 3
    AttributesTileTypeT4TwoDimensionalEncoded AttributesTileType = 4
    AttributesTileTypeBitmapEncoded AttributesTileType = 5
    AttributesTileTypeT6EncodedMsb AttributesTileType = 6
    AttributesTileTypeT4OneDimensionalEncodedMsb AttributesTileType = 7
    AttributesTileTypeT4TwoDimensionalEncodedMsb AttributesTileType = 8
    AttributesTileTypeJbigBitsPerComponentEq1 AttributesTileType = 9
    AttributesTileTypeJpeg AttributesTileType = 10
    AttributesTileTypeJbigBitsPerComponentGr1 AttributesTileType = 11
)

