package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type InformationFrameworkSubtreeSpecification struct {
    Base InformationFrameworkLocalName `asn1:"tag:0"`
    SpecificationFilter InformationFrameworkRefinement `asn1:"optional,tag:4"`
}
