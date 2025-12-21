package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorsLayoutObjectDescriptor struct {
    ObjectType DescriptorsLayoutObjectType `asn1:"optional"`
    DescriptorBody DescriptorsLayoutObjectDescriptorBody `asn1:"optional"`
}
