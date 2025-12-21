package isostandard9541fontattributeset

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SETAlignment struct {
    IsoStandard9541Alignname SETGlobalName `asn1:"tag:0"`
    AlignmentPropertyList SETAlignProperties `asn1:"tag:1"`
}
