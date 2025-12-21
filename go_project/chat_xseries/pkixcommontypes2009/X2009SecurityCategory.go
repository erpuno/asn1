package pkixcommontypes2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009SecurityCategory struct {
    Type asn1.ObjectIdentifier `asn1:"tag:0"`
    Value asn1.RawValue `asn1:"tag:1,explicit"`
}
