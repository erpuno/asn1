package docprofile

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/characterpresentationattributes"
    "tobirama/chat_xseries/geogrpresentationattributes"
    "tobirama/chat_xseries/rastergrpresentationattributes"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorsPresentationAttributes struct {
    ContentArchitectureClass asn1.RawValue `asn1:"optional"`
    CharacterAttributes characterpresentationattributes.AttributesCharacterAttributes `asn1:"optional,tag:0"`
    RasterGraphicsAttributes rastergrpresentationattributes.AttributesRasterGraphicsAttributes `asn1:"optional,tag:1"`
    GeometricGraphicsAttributes geogrpresentationattributes.AttributesGeometricGraphicsAttributes `asn1:"optional,tag:2"`
    ExtContArchPresAttributes []asn1.RawValue `asn1:"optional,tag:6"`
}
