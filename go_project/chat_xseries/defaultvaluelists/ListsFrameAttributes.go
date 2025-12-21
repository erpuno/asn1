package defaultvaluelists

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type ListsFrameAttributes struct {
    Position asn1.RawValue `asn1:"optional"`
    Dimensions asn1.RawValue `asn1:"optional"`
    Transparency asn1.RawValue `asn1:"optional"`
    LayoutPath asn1.RawValue `asn1:"optional"`
    PermittedCategories asn1.RawValue `asn1:"optional"`
    LayoutStreamCategories asn1.RawValue `asn1:"optional"`
    LayoutStreamSubCategories asn1.RawValue `asn1:"optional"`
    Colour asn1.RawValue `asn1:"optional"`
    ColourOfLayoutObject asn1.RawValue `asn1:"optional"`
    ObjectColourTable asn1.RawValue `asn1:"optional"`
    Border asn1.RawValue `asn1:"optional"`
    Sealed asn1.RawValue `asn1:"optional"`
}
