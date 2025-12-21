package characterpresentationattributes

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesTabulationStop struct {
    TabulationReference string `asn1:"tag:0"`
    TabulationPosition int64 `asn1:"tag:1"`
    Alignment int64 `asn1:"tag:2"`
    AlignmentCharacterString []byte `asn1:"optional,tag:3"`
}
