package pkixattributecertificate2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009ClearanceRfc3281 struct {
    PolicyId asn1.ObjectIdentifier `asn1:"tag:0"`
    ClassList X2009ClassList `asn1:"tag:1"`
    SecurityCategories []asn1.RawValue `asn1:"optional,set,tag:2"`
}
