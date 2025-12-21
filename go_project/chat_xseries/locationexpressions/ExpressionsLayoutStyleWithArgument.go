package locationexpressions

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type ExpressionsLayoutStyleWithArgument struct {
    AttributeValueLayoutStyle ExpressionsAttributeValueLayoutStyleSpecification `asn1:"tag:0"`
    NotDefaulting bool `asn1:"tag:1"`
}
