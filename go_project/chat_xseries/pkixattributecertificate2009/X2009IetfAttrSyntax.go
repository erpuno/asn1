package pkixattributecertificate2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009IetfAttrSyntax struct {
    PolicyAuthority asn1.RawValue `asn1:"optional,tag:0"`
    Values []asn1.RawValue
}
