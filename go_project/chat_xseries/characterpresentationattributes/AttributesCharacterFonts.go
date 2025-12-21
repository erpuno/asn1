package characterpresentationattributes

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesCharacterFonts struct {
    PrimaryFont AttributesFontType `asn1:"optional,tag:0"`
    FirstAlternativeFont AttributesFontType `asn1:"optional,tag:1"`
    SecondAlternativeFont AttributesFontType `asn1:"optional,tag:2"`
    ThirdAlternativeFont AttributesFontType `asn1:"optional,tag:3"`
    FourthAlternativeFont AttributesFontType `asn1:"optional,tag:4"`
    FifthAlternativeFont AttributesFontType `asn1:"optional,tag:5"`
    SixthAlternativeFont AttributesFontType `asn1:"optional,tag:6"`
    SeventhAlternativeFont AttributesFontType `asn1:"optional,tag:7"`
    EighthAlternativeFont AttributesFontType `asn1:"optional,tag:8"`
    NinthAlternativeFont AttributesFontType `asn1:"optional,tag:9"`
}
