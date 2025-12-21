package docprofile

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/characterprofileattributes"
    "tobirama/chat_xseries/geogrprofileattributes"
    "tobirama/chat_xseries/rastergrprofileattributes"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorDocApplProfileDefaults struct {
    DocumentArchitectureDefaults DescriptorDocumentArchitectureDefaults `asn1:"optional,tag:0"`
    CharacterContentDefaults characterprofileattributes.AttributesCharacterContentDefaults `asn1:"optional,tag:1"`
    RasterGrContentDefaults rastergrprofileattributes.AttributesRasterGrContentDefaults `asn1:"optional,tag:2"`
    GeoGrContentDefaults geogrprofileattributes.AttributesGeoGrContentDefaults `asn1:"optional,tag:3"`
    ExternalContentArchitectureDefaults []asn1.RawValue `asn1:"optional,tag:7"`
}
