package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorsLogicalObjectDescriptor struct {
    ObjectType DescriptorsLogicalObjectType `asn1:"optional"`
    DescriptorBody DescriptorsLogicalObjectDescriptorBody `asn1:"optional"`
}
