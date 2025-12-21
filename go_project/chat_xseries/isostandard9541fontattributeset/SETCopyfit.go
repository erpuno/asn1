package isostandard9541fontattributeset

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SETCopyfit struct {
    IsoStandard9541Copyfitname SETGlobalName `asn1:"tag:0"`
    CopyfitProperties SETCopyfitProperties `asn1:"tag:1"`
}
