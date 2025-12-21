package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorsLayoutObjectType int

const (
    DescriptorsLayoutObjectTypeDocumentLayoutRoot DescriptorsLayoutObjectType = 0
    DescriptorsLayoutObjectTypePageSet DescriptorsLayoutObjectType = 1
    DescriptorsLayoutObjectTypePage DescriptorsLayoutObjectType = 2
    DescriptorsLayoutObjectTypeFrame DescriptorsLayoutObjectType = 3
    DescriptorsLayoutObjectTypeBlock DescriptorsLayoutObjectType = 4
)

