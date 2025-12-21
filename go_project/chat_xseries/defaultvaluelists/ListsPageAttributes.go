package defaultvaluelists

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type ListsPageAttributes struct {
    Dimensions asn1.RawValue `asn1:"optional"`
    Transparency asn1.RawValue `asn1:"optional"`
    PresentationAttributes asn1.RawValue `asn1:"optional"`
    PagePosition asn1.RawValue `asn1:"optional"`
    MediumType asn1.RawValue `asn1:"optional"`
    PresentationStyle asn1.RawValue `asn1:"optional"`
    LayoutStreamCategories asn1.RawValue `asn1:"optional"`
    LayoutStreamSubCategories asn1.RawValue `asn1:"optional"`
    Colour asn1.RawValue `asn1:"optional"`
    ColourOfLayoutObject asn1.RawValue `asn1:"optional"`
    ObjectColourTable asn1.RawValue `asn1:"optional"`
    ContentBackgroundColour asn1.RawValue `asn1:"optional"`
    ContentForegroundColour asn1.RawValue `asn1:"optional"`
    ContentColourTable asn1.RawValue `asn1:"optional"`
    Sealed asn1.RawValue `asn1:"optional"`
}
