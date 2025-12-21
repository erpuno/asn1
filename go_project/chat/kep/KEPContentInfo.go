package kep

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type KEPContentInfo struct {
    ContentType KEPContentType
    Content asn1.RawValue `asn1:"tag:0,explicit"`
}
