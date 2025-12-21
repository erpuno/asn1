package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorsLogicalObjectType int

const (
    DescriptorsLogicalObjectTypeDocumentLogicalRoot DescriptorsLogicalObjectType = 0
    DescriptorsLogicalObjectTypeCompositeLogicalObject DescriptorsLogicalObjectType = 1
    DescriptorsLogicalObjectTypeBasicLogicalObject DescriptorsLogicalObjectType = 2
)

