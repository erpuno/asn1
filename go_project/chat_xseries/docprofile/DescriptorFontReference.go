package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorFontReference struct {
    UserVisibleName DescriptorsCommentString `asn1:"optional,tag:0"`
    UserReadableComment DescriptorsCommentString `asn1:"optional,tag:1"`
    ReferenceProperties []asn1.RawValue `asn1:"set,tag:2"`
}
