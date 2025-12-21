package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type InformationFrameworkControlOptions struct {
    ServiceControls DirectoryAbstractServiceServiceControlOptions `asn1:"tag:0"`
    SearchOptions DirectoryAbstractServiceSearchControlOptions `asn1:"tag:1"`
    HierarchyOptions DirectoryAbstractServiceHierarchySelections `asn1:"optional,tag:2"`
}
