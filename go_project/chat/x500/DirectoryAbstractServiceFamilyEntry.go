package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DirectoryAbstractServiceFamilyEntry struct {
    Rdn InformationFrameworkRelativeDistinguishedName `asn1:"set"`
    Information []asn1.RawValue
    FamilyInfo []DirectoryAbstractServiceFamilyEntries `asn1:"optional"`
}
