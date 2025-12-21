package isostandard9541fontattributeset

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SETDesignGroup struct {
    GroupCode SETCode `asn1:"tag:0"`
    SubgroupCode SETCode `asn1:"tag:1"`
    SpecificGroupCode SETCode `asn1:"tag:2"`
}
