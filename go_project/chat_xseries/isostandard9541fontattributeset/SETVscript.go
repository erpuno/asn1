package isostandard9541fontattributeset

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SETVscript struct {
    IsoStandard9541Vsname SETGlobalName `asn1:"tag:0"`
    VscriptPropertyList SETVscriptProperties `asn1:"tag:1"`
}
