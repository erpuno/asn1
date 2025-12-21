package rastergrprofileattributes

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/rastergrcodingattributes"
    "tobirama/chat_xseries/rastergrpresentationattributes"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesRasterGrContentDefaults struct {
    Compression rastergrcodingattributes.AttributesCompression `asn1:"optional,tag:8"`
    NumberOfPelsPerTileLine int64 `asn1:"optional,tag:11"`
    NumberOfLinesPerTile int64 `asn1:"optional,tag:12"`
    TilingOffset rastergrpresentationattributes.AttributesCoordinatePair `asn1:"optional,tag:13"`
    TilingType rastergrcodingattributes.AttributesTileType `asn1:"optional,tag:14"`
}
