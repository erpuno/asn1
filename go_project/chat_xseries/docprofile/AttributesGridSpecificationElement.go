package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesGridSpecificationElement struct {
    GridLocation AttributesCMYKColour `asn1:"tag:0"`
    GridValue AttributesGridValue `asn1:"tag:1"`
}
