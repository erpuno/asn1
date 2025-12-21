package subprofiles

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SubprofilesExternalReferences2 struct {
    ReferencesToOtherDocumentsOrDocumentFragments []SubprofilesDocumentOrDocumentFragmentReference `asn1:"optional,set,tag:0"`
    SupersededDocumentsOrDocumentFragments []SubprofilesDocumentOrDocumentFragmentReference `asn1:"optional,set,tag:1"`
}
