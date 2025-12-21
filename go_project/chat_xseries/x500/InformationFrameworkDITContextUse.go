package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type InformationFrameworkDITContextUse struct {
    AttributeType asn1.ObjectIdentifier
    MandatoryContexts []asn1.ObjectIdentifier `asn1:"optional,set,tag:1"`
    OptionalContexts []asn1.ObjectIdentifier `asn1:"optional,set,tag:2"`
}
