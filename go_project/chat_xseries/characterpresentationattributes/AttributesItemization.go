package characterpresentationattributes

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesItemization struct {
    IdentifierAlignment int64 `asn1:"tag:0"`
    IdentifierStartOffset int64 `asn1:"optional,tag:1"`
    IdentifierEndOffset int64 `asn1:"optional,tag:2"`
}
