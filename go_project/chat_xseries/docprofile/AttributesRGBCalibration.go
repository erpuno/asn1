package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesRGBCalibration struct {
    ReferenceWhite AttributesCIERef `asn1:"tag:0"`
    Matrix1 AttributesThreeByThreeMatrix `asn1:"optional,tag:1"`
    LookupTable AttributesColourLookupTable `asn1:"optional,tag:3"`
    Matrix2 AttributesThreeByThreeMatrix `asn1:"optional,tag:2"`
}
