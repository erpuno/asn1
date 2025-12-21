package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DirectoryAbstractServiceFamilyEntries struct {
    FamilyClass asn1.ObjectIdentifier
    FamilyEntries []DirectoryAbstractServiceFamilyEntry
}
