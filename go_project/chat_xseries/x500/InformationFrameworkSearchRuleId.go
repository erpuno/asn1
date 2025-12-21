package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type InformationFrameworkSearchRuleId struct {
    Id int64
    DmdId asn1.ObjectIdentifier `asn1:"tag:0"`
}
