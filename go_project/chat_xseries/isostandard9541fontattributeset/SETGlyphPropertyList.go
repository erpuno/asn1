package isostandard9541fontattributeset

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SETGlyphPropertyList struct {
    IsoStandard9541Gname SETGlobalName `asn1:"tag:0"`
    GlyphProperties SETGlyphProperties `asn1:"tag:1"`
}
