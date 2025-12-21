package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorExternalReferences struct {
    ReferencesToOtherDocuments []DescriptorDocumentReference `asn1:"optional,set,tag:0"`
    SupersededDocuments []DescriptorDocumentReference `asn1:"optional,set,tag:1"`
}
