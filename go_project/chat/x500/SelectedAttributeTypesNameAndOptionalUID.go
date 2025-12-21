package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SelectedAttributeTypesNameAndOptionalUID struct {
    Dn InformationFrameworkDistinguishedName
    Uid SelectedAttributeTypesUniqueIdentifier `asn1:"optional"`
}
