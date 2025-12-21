package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesColourLookupTable struct {
    NumberOfEntries int64 `asn1:"tag:0"`
    M int64 `asn1:"tag:1"`
    N int64 `asn1:"tag:2"`
    ColourTable []AttributesColourTableEntry `asn1:"set,tag:3"`
}
