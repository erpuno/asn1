package rastergrcodingattributes

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/rastergrpresentationattributes"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesRasterGrCodingAttributes struct {
    NumberOfPelsPerLine int64 `asn1:"optional,tag:0"`
    NumberOfLines int64 `asn1:"optional,tag:1"`
    Compression AttributesCompression `asn1:"optional,tag:2"`
    NumberOfDiscardedPels int64 `asn1:"optional,tag:3"`
    BitsPerColourComponent AttributesBitsPerColourComponent `asn1:"optional,tag:4"`
    InterleavingFormat int64 `asn1:"optional,tag:5"`
    NumberOfPelsPerTileLine int64 `asn1:"optional,tag:6"`
    NumberOfLinesPerTile int64 `asn1:"optional,tag:7"`
    TilingOffset rastergrpresentationattributes.AttributesCoordinatePair `asn1:"optional,tag:8"`
    TileTypes []AttributesTileType `asn1:"optional,tag:9"`
    Subsampling AttributesSubsampling `asn1:"optional,tag:10"`
    JpegCodingMode int64 `asn1:"tag:11"`
    JpegQuantizationTable int64 `asn1:"optional,tag:12"`
    JpegHuffmanTable int64 `asn1:"tag:13"`
    JbigDifferentialLayer int64 `asn1:"optional,tag:17"`
    NumberOfLinesPerStripe int64 `asn1:"optional,tag:18"`
}
