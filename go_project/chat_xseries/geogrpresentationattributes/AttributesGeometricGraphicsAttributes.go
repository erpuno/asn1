package geogrpresentationattributes

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesGeometricGraphicsAttributes struct {
    LineRendition AttributesLineRendition `asn1:"optional,tag:1"`
    MarkerRendition AttributesMarkerRendition `asn1:"optional,tag:2"`
    TextRendition AttributesTextRendition `asn1:"optional,tag:3"`
    FilledAreaRendition AttributesFilledAreaRendition `asn1:"optional,tag:4"`
    EdgeRendition AttributesEdgeRendition `asn1:"optional,tag:5"`
    ColourRepresentations AttributesColourRepresentations `asn1:"optional,tag:6"`
    TransparencySpecification AttributesTransparencySpecification `asn1:"optional,tag:7"`
    TransformationSpecification AttributesTransformationSpecification `asn1:"optional,tag:8"`
    RegionOfInterestSpecification AttributesRegionOfInterestSpecification `asn1:"optional,tag:9"`
    PictureOrientation AttributesPictureOrientation `asn1:"optional,tag:10"`
    PictureDimensions AttributesPictureDimensions `asn1:"optional,tag:11"`
}
