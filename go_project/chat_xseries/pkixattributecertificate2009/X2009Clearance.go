package pkixattributecertificate2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009Clearance struct {
    PolicyId asn1.ObjectIdentifier
    ClassList X2009ClassList
    SecurityCategories []asn1.RawValue `asn1:"optional,set"`
}
