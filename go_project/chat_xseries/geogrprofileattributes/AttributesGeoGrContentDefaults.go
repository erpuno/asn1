package geogrprofileattributes

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/geogrpresentationattributes"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesGeoGrContentDefaults struct {
    LineRendition geogrpresentationattributes.AttributesLineRendition `asn1:"optional,tag:1"`
    MarkerRendition geogrpresentationattributes.AttributesMarkerRendition `asn1:"optional,tag:2"`
    TextRendition geogrpresentationattributes.AttributesTextRendition `asn1:"optional,tag:3"`
    FilledAreaRendition geogrpresentationattributes.AttributesFilledAreaRendition `asn1:"optional,tag:4"`
    EdgeRendition geogrpresentationattributes.AttributesEdgeRendition `asn1:"optional,tag:5"`
    ColourRepresentations geogrpresentationattributes.AttributesColourRepresentations `asn1:"optional,tag:6"`
    TransparencySpecification geogrpresentationattributes.AttributesTransparencySpecification `asn1:"optional,tag:7"`
    TransformationSpecification geogrpresentationattributes.AttributesTransformationSpecification `asn1:"optional,tag:8"`
    RegionOfInterestSpecification geogrpresentationattributes.AttributesRegionOfInterestSpecification `asn1:"optional,tag:9"`
    PictureOrientation geogrpresentationattributes.AttributesPictureOrientation `asn1:"optional,tag:10"`
    PictureDimensions geogrpresentationattributes.AttributesPictureDimensions `asn1:"optional,tag:11"`
}
