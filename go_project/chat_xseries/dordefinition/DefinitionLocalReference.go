package dordefinition

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DefinitionLocalReference struct {
    Application []byte `asn1:"optional,tag:0"`
    SpecificReference []byte `asn1:"tag:1"`
}
