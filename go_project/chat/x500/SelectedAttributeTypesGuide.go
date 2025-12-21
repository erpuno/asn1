package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SelectedAttributeTypesGuide struct {
    ObjectClass asn1.ObjectIdentifier `asn1:"optional,tag:0"`
    Criteria SelectedAttributeTypesCriteria `asn1:"tag:1"`
}
