package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesCMYKCalibration struct {
    ReferenceWhite AttributesCIERef `asn1:"tag:0"`
    Comment DescriptorCharacterData `asn1:"optional,tag:1"`
    CmykLut AttributesGridSpecification `asn1:"set,tag:2"`
}
