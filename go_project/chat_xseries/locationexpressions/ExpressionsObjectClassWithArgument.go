package locationexpressions

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type ExpressionsObjectClassWithArgument struct {
    AttributeValueObject ExpressionsAttributeValueClassSpecification `asn1:"tag:0"`
    Defaulting bool `asn1:"tag:1"`
}
