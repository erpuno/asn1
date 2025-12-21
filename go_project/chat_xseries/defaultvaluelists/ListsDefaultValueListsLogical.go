package defaultvaluelists

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type ListsDefaultValueListsLogical struct {
    CompositeLogicalAttributes ListsCompositeLogicalAttributes `asn1:"optional,tag:5"`
    BasicLogicalAttributes ListsBasicLogicalAttributes `asn1:"optional,tag:6"`
}
