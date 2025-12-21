package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesIndexedColour struct {
    Index int64 `asn1:"optional,tag:0"`
}
