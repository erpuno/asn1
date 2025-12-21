package locationexpressions

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type ExpressionsObjectWithArgument struct {
    AttributeValueObject ExpressionsAttributeValueObjectSpecification `asn1:"tag:0"`
    Object ExpressionsObjectLocator `asn1:"optional,tag:1"`
    Counters ExpressionsCountersType `asn1:"optional,tag:2"`
    NotDefaulting bool `asn1:"tag:3"`
}
