package dordefinition

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DefinitionDOR struct {
    AeIdentifier DefinitionAEIdentifier `asn1:"optional,tag:0"`
    LocalReference DefinitionLocalReference `asn1:"tag:1"`
    DataObjectType asn1.ObjectIdentifier
    QualityOfService DefinitionQualityOfService `asn1:"tag:2"`
    Token DefinitionToken `asn1:"optional,tag:3"`
}
