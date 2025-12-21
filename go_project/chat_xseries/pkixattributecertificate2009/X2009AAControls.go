package pkixattributecertificate2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009AAControls struct {
    PathLenConstraint int64 `asn1:"optional"`
    PermittedAttrs X2009AttrSpec `asn1:"optional,tag:0"`
    ExcludedAttrs X2009AttrSpec `asn1:"optional,tag:1"`
    PermitUnSpecified bool
}
