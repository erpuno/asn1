package textunits

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/identifiersandexpressions"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type UnitsContentPortionAttributes struct {
    ContentIdentifierLayout identifiersandexpressions.ExpressionsContentPortionIdentifier `asn1:"optional"`
    ContentIdentifierLogical identifiersandexpressions.ExpressionsContentPortionIdentifier `asn1:"optional,tag:4"`
    TypeOfCoding UnitsTypeOfCoding `asn1:"optional"`
    CodingAttributes asn1.RawValue `asn1:"optional"`
    AlternativeRepresentation UnitsAlternativeRepresentation `asn1:"optional,tag:3"`
}
