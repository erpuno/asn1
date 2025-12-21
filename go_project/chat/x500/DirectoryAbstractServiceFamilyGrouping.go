package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DirectoryAbstractServiceFamilyGrouping int

const (
    DirectoryAbstractServiceFamilyGroupingEntryOnly DirectoryAbstractServiceFamilyGrouping = 1
    DirectoryAbstractServiceFamilyGroupingCompoundEntry DirectoryAbstractServiceFamilyGrouping = 2
    DirectoryAbstractServiceFamilyGroupingStrands DirectoryAbstractServiceFamilyGrouping = 3
    DirectoryAbstractServiceFamilyGroupingMultiStrand DirectoryAbstractServiceFamilyGrouping = 4
)

