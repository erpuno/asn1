package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesColourTable struct {
    ColourSpaceId int64 `asn1:"tag:0"`
    ColourTableEntries []asn1.RawValue `asn1:"set,tag:1"`
}
