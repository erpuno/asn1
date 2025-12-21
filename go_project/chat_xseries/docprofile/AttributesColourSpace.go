package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesColourSpace struct {
    ColourSpaceId int64 `asn1:"tag:0"`
    ColourSpaceType AttributesColourSpaceType `asn1:"tag:1"`
    ColourSpaceName DescriptorCharacterData `asn1:"optional,tag:2"`
    ColourDataScaling AttributesColourDataScaling `asn1:"optional,tag:3"`
    CalibrationData AttributesCalibrationData `asn1:"optional,tag:4"`
}
